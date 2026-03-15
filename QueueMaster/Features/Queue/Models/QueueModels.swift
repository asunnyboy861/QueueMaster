import Foundation
import MusicKit

struct MusicQueueItem: Identifiable, Codable, Hashable, Transferable {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: URL?
    let durationInSeconds: Int
    let playParametersData: Data?
    
    var artworkImage: UIImage? {
        nil
    }
    
    init(id: String, title: String, artistName: String, albumTitle: String? = nil, artworkURL: URL? = nil, durationInSeconds: Int, playParametersData: Data? = nil) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.artworkURL = artworkURL
        self.durationInSeconds = durationInSeconds
        self.playParametersData = playParametersData
    }
    
    init(from musicItem: MusicKit.MusicItem) {
        self.id = musicItem.id.rawValue
        self.title = musicItem.title
        self.artistName = musicItem.artistName
        self.albumTitle = musicItem.albumTitle
        self.artworkURL = musicItem.artwork?.url(width: 300, height: 300)
        
        if let playableItem = musicItem as? any MusicKit.Playable {
            self.durationInSeconds = Int(playableItem.duration ?? 0)
            if let params = playableItem.playParameters {
                self.playParametersData = try? JSONEncoder().encode(PlayParametersWrapper(id: params.id.rawValue))
            } else {
                self.playParametersData = nil
            }
        } else {
            self.durationInSeconds = 0
            self.playParametersData = nil
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .item)
    }
}

struct PlayParametersWrapper: Codable {
    let id: String
}

struct QueueSnapshot: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let items: [MusicQueueItem]
    let currentIndex: Int?
    let source: SnapshotSource
    
    init(id: UUID = UUID(), timestamp: Date = Date(), items: [MusicQueueItem], currentIndex: Int? = nil, source: SnapshotSource = .manual) {
        self.id = id
        self.timestamp = timestamp
        self.items = items
        self.currentIndex = currentIndex
        self.source = source
    }
}

enum InsertPosition: Codable, Hashable {
    case next
    case last
    case atIndex(Int)
}

enum SnapshotSource: String, Codable, Hashable {
    case manual
    case auto
    case system
}

struct PlayStatistics: Codable {
    var totalQueueEdits: Int
    var totalRestores: Int
    var mostEditedTimeOfDay: String
    var favoriteQueueLength: Int
    
    init() {
        self.totalQueueEdits = 0
        self.totalRestores = 0
        self.mostEditedTimeOfDay = "Unknown"
        self.favoriteQueueLength = 0
    }
}

struct QueueAction: Codable {
    let id: UUID
    let timestamp: Date
    let type: ActionType
    let items: [MusicQueueItem]
    let affectedIndex: Int?
    let previousIndex: Int?
    
    enum ActionType: String, Codable {
        case add
        case remove
        case reorder
        case clear
        case restore
    }
}
