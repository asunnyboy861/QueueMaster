import Foundation
import MusicKit
import MediaPlayer
import Combine

@MainActor
class MusicService: ObservableObject {
    static let shared = MusicService()
    
    @Published var currentQueue: [MusicQueueItem] = []
    @Published var currentItem: MusicQueueItem?
    @Published var isPlaying: Bool = false
    @Published var playbackTime: TimeInterval = 0
    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
    
    private let applicationMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
        checkAuthorization()
    }
    
    func checkAuthorization() {
        authorizationStatus = MusicAuthorization.currentStatus
    }
    
    func requestAuthorization() async -> Bool {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
        return status == .authorized
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .MPMusicPlayerControllerNowPlayingItemDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateNowPlaying()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .MPMusicPlayerControllerPlaybackStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePlaybackState()
            }
            .store(in: &cancellables)
        
        applicationMusicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    private func updateNowPlaying() {
        if let item = applicationMusicPlayer.nowPlayingItem {
            currentItem = createMusicQueueItem(from: item)
        }
    }
    
    private func updatePlaybackState() {
        isPlaying = applicationMusicPlayer.playbackState == .playing
    }
    
    private func createMusicQueueItem(from item: MPMediaItem) -> MusicQueueItem {
        return MusicQueueItem(
            id: String(item.persistentID),
            title: item.title ?? "Unknown",
            artistName: item.artist ?? "Unknown Artist",
            albumTitle: item.albumTitle,
            artworkURL: extractArtworkURL(from: item),
            durationInSeconds: Int(item.playbackDuration),
            playParametersData: extractPlayParameters(from: item)
        )
    }
    
    /// Extract artwork URL from media item
    /// - Parameter item: MPMediaItem
    /// - Returns: Cached artwork URL
    private func extractArtworkURL(from item: MPMediaItem) -> URL? {
        guard let artwork = item.artwork else { return nil }
        
        // Get high-resolution image
        let imageSize = CGSize(width: 300, height: 300)
        if let image = artwork.image(at: imageSize) {
            return cacheImage(image)
        }
        return nil
    }
    
    /// Cache image to temporary directory
    /// - Parameter image: UIImage to cache
    /// - Returns: File URL of cached image
    private func cacheImage(_ image: UIImage) -> URL? {
        do {
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "artwork_\(UUID().uuidString).jpg"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            if let data = image.jpegData(compressionQuality: 0.8) {
                try data.write(to: fileURL)
                return fileURL
            }
        } catch {
            print("⚠️ Failed to cache artwork: \(error)")
        }
        return nil
    }
    
    /// Extract play parameters from media item
    /// - Parameter item: MPMediaItem
    /// - Returns: Encoded play parameters data
    private func extractPlayParameters(from item: MPMediaItem) -> Data? {
        let params = PlayParametersWrapper(id: String(item.persistentID))
        return try? JSONEncoder().encode(params)
    }
    
    /// Sync with system queue
    /// Note: Due to iOS limitations, full system queue sync is challenging
    /// This method attempts to get the current playing queue
    func syncWithSystemQueue() {
        if #available(iOS 17.0, *) {
            syncWithSystemQueueModern()
        } else {
            syncWithSystemQueueLegacy()
        }
    }
    
    /// Modern sync method (iOS 17+)
    @available(iOS 17.0, *)
    private func syncWithSystemQueueModern() {
        if authorizationStatus == .authorized {
            updateCurrentQueueFromNowPlaying()
        }
    }
    
    /// Legacy sync method (iOS 17 and below)
    private func syncWithSystemQueueLegacy() {
        updateCurrentQueueFromNowPlaying()
    }
    
    /// Update queue from current playing item
    private func updateCurrentQueueFromNowPlaying() {
        if let item = applicationMusicPlayer.nowPlayingItem {
            let queueItem = createMusicQueueItem(from: item)
            
            // Update current queue if needed
            if currentQueue.isEmpty {
                currentQueue = [queueItem]
            }
            
            currentItem = queueItem
        }
    }
    
    func play(item: MusicQueueItem) async throws {
        let storeID = item.id
        let predicate = MPMediaPropertyPredicate(value: storeID, forProperty: MPMediaItemPropertyPersistentID)
        let query = MPMediaQuery.songs()
        query.addFilterPredicate(predicate)
        
        if let song = query.items?.first {
            let storeIDString = String(song.persistentID)
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [storeIDString])
            applicationMusicPlayer.setQueue(with: descriptor)
            applicationMusicPlayer.play()
        }
    }
    
    func pause() {
        applicationMusicPlayer.pause()
        isPlaying = false
    }
    
    func resume() {
        applicationMusicPlayer.play()
        isPlaying = true
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    func next() {
        applicationMusicPlayer.skipToNextItem()
    }
    
    func previous() {
        applicationMusicPlayer.skipToPreviousItem()
    }
    
    func seek(to time: TimeInterval) {
        applicationMusicPlayer.currentPlaybackTime = time
        playbackTime = time
    }
    
    func getCurrentPlaybackTime() -> TimeInterval {
        return applicationMusicPlayer.currentPlaybackTime
    }
    
    func setQueue(_ items: [MusicQueueItem]) async throws {
        var storeIDs: [String] = []
        
        for item in items {
            if let uint64ID = UInt64(item.id) {
                storeIDs.append(String(uint64ID))
            }
        }
        
        if !storeIDs.isEmpty {
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
            applicationMusicPlayer.setQueue(with: descriptor)
        }
    }
    
    func addToQueue(_ item: MusicQueueItem, position: InsertPosition) async throws {
        if let uint64ID = UInt64(item.id) {
            let storeIDString = String(uint64ID)
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [storeIDString])
            applicationMusicPlayer.append(descriptor)
        }
    }
    
    func removeFromQueue(at index: Int) {
    }
    
    func clearQueue() {
        applicationMusicPlayer.stop()
        currentQueue = []
        currentItem = nil
        isPlaying = false
    }
}
