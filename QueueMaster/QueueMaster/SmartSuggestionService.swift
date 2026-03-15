import Foundation

/// Smart suggestion service for queue optimization
class SmartSuggestionService {
    static let shared = SmartSuggestionService()
    
    private init() {}
    
    // MARK: - Queue Analysis
    
    /// Analyze queue and provide suggestions
    /// - Parameter queue: Current music queue
    /// - Returns: Array of suggestions
    func analyzeQueue(_ queue: [MusicQueueItem]) -> [QueueSuggestion] {
        var suggestions: [QueueSuggestion] = []
        
        // Check for duplicates
        if let duplicates = findDuplicates(in: queue) {
            suggestions.append(.duplicateSongs(duplicates))
        }
        
        // Check queue length
        if queue.isEmpty {
            suggestions.append(.emptyQueue)
        } else if queue.count == 1 {
            suggestions.append(.shortQueue)
        }
        
        // Check duration variety
        if let durationIssue = analyzeDurationVariety(in: queue) {
            suggestions.append(durationIssue)
        }
        
        return suggestions
    }
    
    /// Find duplicate songs in queue
    private func findDuplicates(in queue: [MusicQueueItem]) -> [MusicQueueItem]? {
        var seen = Set<String>()
        var duplicates: [MusicQueueItem] = []
        
        for item in queue {
            let key = "\(item.title)-\(item.artistName)"
            if seen.contains(key) {
                duplicates.append(item)
            } else {
                seen.insert(key)
            }
        }
        
        return duplicates.isEmpty ? nil : duplicates
    }
    
    /// Analyze duration variety in queue
    private func analyzeDurationVariety(in queue: [MusicQueueItem]) -> QueueSuggestion? {
        guard queue.count > 3 else { return nil }
        
        let durations = queue.map { $0.durationInSeconds }
        let averageDuration = durations.reduce(0, +) / durations.count
        
        // Check if all songs are very similar in length
        let variance = durations.reduce(0) { $0 + pow(Double($1 - averageDuration), 2) } / Double(durations.count)
        
        if variance < 100 { // Very low variance
            return .lowDurationVariety
        }
        
        return nil
    }
    
    // MARK: - Smart Suggestions
    
    /// Get suggestion message for UI
    func getSuggestionMessage(for suggestion: QueueSuggestion) -> String {
        switch suggestion {
        case .duplicateSongs(let songs):
            return "You have \(songs.count) duplicate song(s) in your queue."
        case .emptyQueue:
            return "Your queue is empty. Add some songs to get started!"
        case .shortQueue:
            return "Your queue is short. Consider adding more songs."
        case .lowDurationVariety:
            return "Your queue has similar song lengths. Add variety for better listening experience."
        }
    }
    
    /// Get suggestion icon
    func getSuggestionIcon(for suggestion: QueueSuggestion) -> String {
        switch suggestion {
        case .duplicateSongs:
            return "exclamationmark.triangle"
        case .emptyQueue:
            return "music.note.list"
        case .shortQueue:
            return "plus.circle"
        case .lowDurationVariety:
            return "waveform"
        }
    }
}

// MARK: - Models

enum QueueSuggestion: Identifiable {
    case duplicateSongs([MusicQueueItem])
    case emptyQueue
    case shortQueue
    case lowDurationVariety
    
    var id: String {
        switch self {
        case .duplicateSongs:
            return "duplicates"
        case .emptyQueue:
            return "empty"
        case .shortQueue:
            return "short"
        case .lowDurationVariety:
            return "variety"
        }
    }
}
