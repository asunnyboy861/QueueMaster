import Foundation
import Combine

@MainActor
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var queueHistory: [QueueSnapshot] = []
    @Published var playStatistics: PlayStatistics = PlayStatistics()
    
    private let maxHistoryCount: Int = 100
    private let userDefaultsKey = "QueueHistory"
    private let statisticsKey = "PlayStatistics"
    
    private init() {
        loadHistory()
        loadStatistics()
    }
    
    func saveSnapshot(_ snapshot: QueueSnapshot) {
        queueHistory.insert(snapshot, at: 0)
        
        if queueHistory.count > maxHistoryCount {
            queueHistory.removeLast()
        }
        
        playStatistics.totalQueueEdits += 1
        updateFavoriteQueueLength()
        saveHistory()
        saveStatistics()
    }
    
    func loadSnapshots() -> [QueueSnapshot] {
        return queueHistory
    }
    
    func deleteSnapshot(_ id: UUID) {
        queueHistory.removeAll { $0.id == id }
        saveHistory()
    }
    
    func deleteAllSnapshots() {
        queueHistory.removeAll()
        saveHistory()
    }
    
    func getStatistics() -> PlayStatistics {
        return playStatistics
    }
    
    func incrementRestoreCount() {
        playStatistics.totalRestores += 1
        saveStatistics()
    }
    
    func exportHistory() -> URL? {
        let exportData = QueueHistoryExport(
            history: queueHistory,
            statistics: playStatistics,
            exportDate: Date()
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportData)
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "QueueHistory_\(Date().ISO8601Format()).json"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to export history: \(error)")
            return nil
        }
    }
    
    func importHistory(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importedData = try decoder.decode(QueueHistoryExport.self, from: data)
            
            queueHistory = importedData.history
            playStatistics = importedData.statistics
            
            saveHistory()
            saveStatistics()
            
            return true
        } catch {
            print("Failed to import history: \(error)")
            return false
        }
    }
    
    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(queueHistory)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            queueHistory = try decoder.decode([QueueSnapshot].self, from: data)
        } catch {
            print("Failed to load history: \(error)")
        }
    }
    
    private func saveStatistics() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(playStatistics)
            UserDefaults.standard.set(data, forKey: statisticsKey)
        } catch {
            print("Failed to save statistics: \(error)")
        }
    }
    
    private func loadStatistics() {
        guard let data = UserDefaults.standard.data(forKey: statisticsKey) else { return }
        
        do {
            playStatistics = try JSONDecoder().decode(PlayStatistics.self, from: data)
        } catch {
            print("Failed to load statistics: \(error)")
        }
    }
    
    private func updateFavoriteQueueLength() {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 0..<6:
            timeOfDay = "Night"
        case 6..<12:
            timeOfDay = "Morning"
        case 12..<18:
            timeOfDay = "Afternoon"
        default:
            timeOfDay = "Evening"
        }
        
        playStatistics.mostEditedTimeOfDay = timeOfDay
        
        if queueHistory.isEmpty {
            playStatistics.favoriteQueueLength = currentAverageQueueLength()
        } else {
            let avgLength = queueHistory.reduce(0) { $0 + $1.items.count } / queueHistory.count
            playStatistics.favoriteQueueLength = avgLength
        }
    }
    
    private func currentAverageQueueLength() -> Int {
        guard !queueHistory.isEmpty else { return 0 }
        return queueHistory.reduce(0) { $0 + $1.items.count } / queueHistory.count
    }
    
    func getSnapshot(at index: Int) -> QueueSnapshot? {
        guard index >= 0 && index < queueHistory.count else { return nil }
        return queueHistory[index]
    }
    
    func getSnapshot(by id: UUID) -> QueueSnapshot? {
        return queueHistory.first { $0.id == id }
    }
}

struct QueueHistoryExport: Codable {
    let history: [QueueSnapshot]
    let statistics: PlayStatistics
    let exportDate: Date
}
