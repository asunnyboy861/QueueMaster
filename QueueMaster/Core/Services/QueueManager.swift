import Foundation
import Combine

@MainActor
class QueueManager: ObservableObject {
    static let shared = QueueManager()
    
    @Published var currentQueue: [MusicQueueItem] = []
    @Published var queueHistory: [QueueSnapshot] = []
    @Published var isQueueModified: Bool = false
    @Published var currentIndex: Int = 0
    @Published var pendingSnapshot: QueueSnapshot?
    
    private var undoStack: [QueueAction] = []
    private var redoStack: [QueueAction] = []
    private let maxHistory: Int = 50
    private var autoSaveTimer: Timer?
    private let musicService = MusicService.shared
    
    private init() {
        startAutoSave()
    }
    
    func addToQueue(_ item: MusicQueueItem, position: InsertPosition) {
        let action = QueueAction(
            id: UUID(),
            timestamp: Date(),
            type: .add,
            items: [item],
            affectedIndex: nil,
            previousIndex: nil
        )
        
        recordAction(action)
        
        switch position {
        case .next:
            if currentIndex + 1 < currentQueue.count {
                currentQueue.insert(item, at: currentIndex + 1)
            } else {
                currentQueue.append(item)
            }
        case .last:
            currentQueue.append(item)
        case .atIndex(let index):
            let safeIndex = min(index, currentQueue.count)
            currentQueue.insert(item, at: safeIndex)
        }
        
        isQueueModified = true
        syncToMusicService()
    }
    
    func removeFromQueue(_ item: MusicQueueItem) {
        guard let index = currentQueue.firstIndex(where: { $0.id == item.id }) else { return }
        
        let action = QueueAction(
            id: UUID(),
            timestamp: Date(),
            type: .remove,
            items: [item],
            affectedIndex: index,
            previousIndex: nil
        )
        
        recordAction(action)
        currentQueue.remove(at: index)
        isQueueModified = true
        syncToMusicService()
    }
    
    func removeFromQueue(at index: Int) {
        guard index >= 0 && index < currentQueue.count else { return }
        
        let item = currentQueue[index]
        let action = QueueAction(
            id: UUID(),
            timestamp: Date(),
            type: .remove,
            items: [item],
            affectedIndex: index,
            previousIndex: nil
        )
        
        recordAction(action)
        currentQueue.remove(at: index)
        
        if index < currentIndex {
            currentIndex = max(0, currentIndex - 1)
        } else if index == currentIndex && currentIndex >= currentQueue.count {
            currentIndex = max(0, currentQueue.count - 1)
        }
        
        isQueueModified = true
        syncToMusicService()
    }
    
    func reorderQueue(from source: IndexSet, to destination: Int) {
        let movedItems = source.map { currentQueue[$0] }
        
        let action = QueueAction(
            id: UUID(),
            timestamp: Date(),
            type: .reorder,
            items: movedItems,
            affectedIndex: destination,
            previousIndex: source.first
        )
        
        recordAction(action)
        currentQueue.move(fromOffsets: source, toOffset: destination)
        isQueueModified = true
        syncToMusicService()
    }
    
    func clearQueue() {
        guard !currentQueue.isEmpty else { return }
        
        let action = QueueAction(
            id: UUID(),
            timestamp: Date(),
            type: .clear,
            items: currentQueue,
            affectedIndex: nil,
            previousIndex: currentIndex
        )
        
        recordAction(action)
        
        let snapshot = saveQueueSnapshot(source: .manual)
        queueHistory.insert(snapshot, at: 0)
        if queueHistory.count > maxHistory {
            queueHistory.removeLast()
        }
        
        currentQueue.removeAll()
        currentIndex = 0
        isQueueModified = true
        
        Task {
            try? await musicService.clearQueue()
        }
    }
    
    func saveQueueSnapshot(source: SnapshotSource = .manual) -> QueueSnapshot {
        let snapshot = QueueSnapshot(
            id: UUID(),
            timestamp: Date(),
            items: currentQueue,
            currentIndex: currentIndex,
            source: source
        )
        return snapshot
    }
    
    func restoreQueueSnapshot(_ snapshot: QueueSnapshot) {
        let action = QueueAction(
            id: UUID(),
            timestamp: Date(),
            type: .restore,
            items: currentQueue,
            affectedIndex: nil,
            previousIndex: currentIndex
        )
        
        recordAction(action)
        
        currentQueue = snapshot.items
        currentIndex = snapshot.currentIndex ?? 0
        isQueueModified = true
        syncToMusicService()
    }
    
    func undoLastAction() {
        guard let action = undoStack.popLast() else { return }
        
        redoStack.append(action)
        
        switch action.type {
        case .add:
            if let item = action.items.first {
                currentQueue.removeAll { $0.id == item.id }
            }
        case .remove:
            if let index = action.affectedIndex, let item = action.items.first {
                currentQueue.insert(item, at: min(index, currentQueue.count))
            }
        case .reorder:
            break
        case .clear:
            currentQueue = action.items
            if let prevIndex = action.previousIndex {
                currentIndex = prevIndex
            }
        case .restore:
            if let index = action.previousIndex {
                currentIndex = index
            }
        }
        
        isQueueModified = true
        syncToMusicService()
    }
    
    func redoLastAction() {
        guard let action = redoStack.popLast() else { return }
        
        undoStack.append(action)
        
        switch action.type {
        case .add:
            if let item = action.items.first {
                currentQueue.append(item)
            }
        case .remove:
            if let index = action.affectedIndex {
                currentQueue.remove(at: min(index, currentQueue.count - 1))
            }
        case .reorder:
            break
        case .clear:
            currentQueue.removeAll()
            currentIndex = 0
        case .restore:
            break
        }
        
        isQueueModified = true
        syncToMusicService()
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    private func recordAction(_ action: QueueAction) {
        undoStack.append(action)
        if undoStack.count > maxHistory {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }
    
    private func syncToMusicService() {
        Task {
            do {
                try await musicService.setQueue(currentQueue)
            } catch {
                print("Failed to sync to MusicService: \(error)")
            }
        }
    }
    
    private func startAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30) { [weak self] _ in
            Task { @MainActor in
                self?.autoSaveSnapshot()
            }
        }
    }
    
    private func autoSaveSnapshot() {
        guard isQueueModified && !currentQueue.isEmpty else { return }
        
        let snapshot = saveQueueSnapshot(source: .auto)
        queueHistory.insert(snapshot, at: 0)
        
        if queueHistory.count > maxHistory {
            queueHistory.removeLast()
        }
        
        pendingSnapshot = snapshot
    }
    
    func detectQueueClear() -> Bool {
        return currentQueue.isEmpty && queueHistory.count > 0
    }
    
    func getLastSnapshot() -> QueueSnapshot? {
        return queueHistory.first
    }
    
    func loadQueue(from snapshot: QueueSnapshot) {
        currentQueue = snapshot.items
        currentIndex = snapshot.currentIndex ?? 0
        isQueueModified = false
    }
    
    func syncWithMusicService() {
        Task { @MainActor in
            musicService.syncWithSystemQueue()
            currentQueue = musicService.currentQueue
            currentIndex = 0
        }
    }
}
