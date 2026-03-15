import Foundation
import Combine
import MusicKit

@MainActor
class QueueViewModel: ObservableObject {
    @Published var currentQueue: [MusicQueueItem] = []
    @Published var currentIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var currentItem: MusicQueueItem?
    @Published var playbackTime: TimeInterval = 0
    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
    @Published var isLoading: Bool = false
    @Published var showRestoreAlert: Bool = false
    @Published var pendingSnapshot: QueueSnapshot?
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let queueManager = QueueManager.shared
    private let musicService = MusicService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var canUndo: Bool {
        queueManager.canUndo
    }
    
    var canRedo: Bool {
        queueManager.canRedo
    }
    
    var totalDuration: Int {
        currentQueue.reduce(0) { $0 + $1.durationInSeconds }
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        queueManager.$currentQueue
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentQueue)
        
        queueManager.$currentIndex
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentIndex)
        
        musicService.$isPlaying
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPlaying)
        
        musicService.$currentItem
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentItem)
        
        musicService.$playbackTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$playbackTime)
        
        musicService.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$authorizationStatus)
        
        queueManager.$pendingSnapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                if let snapshot = snapshot {
                    self?.pendingSnapshot = snapshot
                    self?.showRestoreAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    func requestAuthorization() async {
        let authorized = await musicService.requestAuthorization()
        if authorized {
            await loadQueue()
        }
    }
    
    func loadQueue() async {
        isLoading = true
        queueManager.syncWithMusicService()
        
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
        } catch {}
        
        isLoading = false
    }
    
    func syncWithAppleMusic() {
        isLoading = true
        musicService.syncWithSystemQueue()
        currentQueue = musicService.currentQueue
        if let item = musicService.currentItem,
           let index = currentQueue.firstIndex(where: { $0.id == item.id }) {
            currentIndex = index
        }
        isLoading = false
    }
    
    func playItem(_ item: MusicQueueItem) async {
        do {
            try await musicService.play(item: item)
        } catch {
            showError(message: "Failed to play: \(error.localizedDescription)")
        }
    }
    
    func playItem(at index: Int) async {
        guard index >= 0 && index < currentQueue.count else { return }
        let item = currentQueue[index]
        await playItem(item)
        currentIndex = index
    }
    
    func togglePlayPause() {
        musicService.togglePlayPause()
    }
    
    func next() {
        musicService.next()
    }
    
    func previous() {
        musicService.previous()
    }
    
    func seek(to time: TimeInterval) {
        musicService.seek(to: time)
    }
    
    func removeItem(at index: Int) {
        queueManager.removeFromQueue(at: index)
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        queueManager.reorderQueue(from: source, to: destination)
    }
    
    func clearQueue() {
        queueManager.clearQueue()
    }
    
    func undo() {
        queueManager.undoLastAction()
    }
    
    func redo() {
        queueManager.redoLastAction()
    }
    
    func saveSnapshot() {
        let snapshot = queueManager.saveQueueSnapshot()
        HistoryManager.shared.saveSnapshot(snapshot)
    }
    
    func restoreSnapshot(_ snapshot: QueueSnapshot) {
        queueManager.restoreQueueSnapshot(snapshot)
        HistoryManager.shared.incrementRestoreCount()
    }
    
    func dismissRestoreAlert() {
        showRestoreAlert = false
        pendingSnapshot = nil
    }
    
    func restoreFromPending() {
        if let snapshot = pendingSnapshot {
            restoreSnapshot(snapshot)
        }
        dismissRestoreAlert()
    }
    
    func checkForQueueClear() {
        if queueManager.detectQueueClear() {
            if let snapshot = queueManager.getLastSnapshot() {
                pendingSnapshot = snapshot
                showRestoreAlert = true
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
