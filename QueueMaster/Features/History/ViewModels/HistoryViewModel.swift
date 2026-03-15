import Foundation
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var queueHistory: [QueueSnapshot] = []
    @Published var playStatistics: PlayStatistics = PlayStatistics()
    @Published var isLoading: Bool = false
    @Published var showExportSheet: Bool = false
    @Published var showImportPicker: Bool = false
    @Published var exportURL: URL?
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let historyManager = HistoryManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        historyManager.$queueHistory
            .receive(on: DispatchQueue.main)
            .assign(to: &$queueHistory)
        
        historyManager.$playStatistics
            .receive(on: DispatchQueue.main)
            .assign(to: &$playStatistics)
    }
    
    func loadHistory() {
        isLoading = true
        queueHistory = historyManager.loadSnapshots()
        playStatistics = historyManager.getStatistics()
        isLoading = false
    }
    
    func deleteSnapshot(_ snapshot: QueueSnapshot) {
        historyManager.deleteSnapshot(snapshot.id)
    }
    
    func deleteAllHistory() {
        historyManager.deleteAllSnapshots()
    }
    
    func restoreSnapshot(_ snapshot: QueueSnapshot) {
        QueueManager.shared.restoreQueueSnapshot(snapshot)
        historyManager.incrementRestoreCount()
    }
    
    func exportHistory() {
        if let url = historyManager.exportHistory() {
            exportURL = url
            showExportSheet = true
        } else {
            showError(message: "Failed to export history")
        }
    }
    
    func importHistory(from url: URL) {
        if historyManager.importHistory(from: url) {
            loadHistory()
        } else {
            showError(message: "Failed to import history")
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    func getFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    func getSourceLabel(_ source: SnapshotSource) -> String {
        switch source {
        case .manual:
            return "Manual Save"
        case .auto:
            return "Auto Save"
        case .system:
            return "System"
        }
    }
}
