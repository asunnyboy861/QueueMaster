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
    
    private let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private var cancellables = Set<AnyCancellable>()
    private var timeObserver: Timer?
    
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
        
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    private func updateNowPlaying() {
        if let item = musicPlayer.nowPlayingItem {
            currentItem = MusicQueueItem(from: item)
        }
    }
    
    private func updatePlaybackState() {
        isPlaying = musicPlayer.playbackState == .playing
    }
    
    func play(item: MusicQueueItem) async throws {
        let request = MusicCatalogResourceRequest<MusicKit.Song>(matching: \.id, equalTo: MusicItemID(item.id))
        let response = try await request.response()
        if let song = response.items.first {
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [item.id])
            musicPlayer.setQueue(with: descriptor)
            musicPlayer.play()
        }
    }
    
    func pause() {
        musicPlayer.pause()
        isPlaying = false
    }
    
    func resume() {
        musicPlayer.play()
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
        musicPlayer.skipToNextItem()
    }
    
    func previous() {
        musicPlayer.skipToPreviousItem()
    }
    
    func seek(to time: TimeInterval) {
        musicPlayer.currentPlaybackTime = time
        playbackTime = time
    }
    
    func getCurrentPlaybackTime() -> TimeInterval {
        return musicPlayer.currentPlaybackTime
    }
    
    func setQueue(_ items: [MusicQueueItem]) async throws {
        let storeIDs = items.map { $0.id }
        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
        musicPlayer.setQueue(with: descriptor)
        currentQueue = items
    }
    
    func addToQueue(_ item: MusicQueueItem, position: InsertPosition) async throws {
        var queueItems = currentQueue
        switch position {
        case .next:
            if let currentIndex = queueItems.firstIndex(where: { $0.id == currentItem?.id }) {
                queueItems.insert(item, at: currentIndex + 1)
            } else {
                queueItems.append(item)
            }
        case .last:
            queueItems.append(item)
        case .atIndex(let index):
            if index <= queueItems.count {
                queueItems.insert(item, at: index)
            } else {
                queueItems.append(item)
            }
        }
        
        let storeIDs = queueItems.map { $0.id }
        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
        musicPlayer.setQueue(with: descriptor)
        currentQueue = queueItems
    }
    
    func removeFromQueue(at index: Int) {
        guard index < currentQueue.count else { return }
        currentQueue.remove(at: index)
        let storeIDs = currentQueue.map { $0.id }
        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
        musicPlayer.setQueue(with: descriptor)
    }
    
    func clearQueue() {
        musicPlayer.setQueue(with: [])
        currentQueue = []
    }
    
    func startPlaybackTimeObserver() {
        timeObserver = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.playbackTime = self?.getCurrentPlaybackTime() ?? 0
            }
        }
    }
    
    func stopPlaybackTimeObserver() {
        timeObserver?.invalidate()
        timeObserver = nil
    }
    
    func syncWithSystemQueue() {
        updateNowPlaying()
        updatePlaybackState()
    }
}
