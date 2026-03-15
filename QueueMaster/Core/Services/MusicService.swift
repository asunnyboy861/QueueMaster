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
    private let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
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
        
        applicationMusicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    private func updateNowPlaying() {
        if let item = applicationMusicPlayer.nowPlayingItem {
            currentItem = MusicQueueItem(from: item)
        }
        updateCurrentQueue()
    }
    
    private func updatePlaybackState() {
        isPlaying = applicationMusicPlayer.playbackState == .playing
    }
    
    private func updateCurrentQueue() {
        if let queue = applicationMusicPlayer.queue?.items {
            currentQueue = queue.map { MusicQueueItem(from: $0) }
        }
    }
    
    func play(item: MusicQueueItem) async throws {
        guard let playParamsData = item.playParametersData,
              let wrapper = try? JSONDecoder().decode(PlayParametersWrapper.self, from: playParamsData) else {
            let request = MusicCatalogResourceRequest<MusicKit.Song>(matching: \.id, equalTo: MusicItemID(item.id))
            let response = try await request.response()
            if let song = response.items.first {
                try await Player.shared.play(item: song)
            }
            return
        }
        
        let playParams = PlayParameters(id: MusicItemID(wrapper.id))
        let request = MusicCatalogResourceRequest<MusicKit.Song>(matching: \.id, equalTo: MusicItemID(item.id))
        let response = try await request.response()
        if let song = response.items.first {
            try await Player.shared.play(item: song)
        }
    }
    
    func pause() {
        Player.shared.pause()
        isPlaying = false
    }
    
    func resume() {
        Task {
            try? await Player.shared.play()
            isPlaying = true
        }
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
        Player.shared.seek(to: time)
        playbackTime = time
    }
    
    func getCurrentPlaybackTime() -> TimeInterval {
        return Player.shared.playbackTime
    }
    
    func setQueue(_ items: [MusicQueueItem]) async throws {
        var songIDs: [MusicItemID] = []
        for item in items {
            songIDs.append(MusicItemID(item.id))
        }
        
        var request = MusicCatalogResourceRequest<MusicKit.Song>(matching: \.id)
        request.filter = songIDs.contains
        
        var songArray: [MusicKit.Song] = []
        for id in songIDs {
            let songRequest = MusicCatalogResourceRequest<MusicKit.Song>(matching: \.id, equalTo: id)
            if let song = try await songRequest.response().items.first {
                songArray.append(song)
            }
        }
        
        if !songArray.isEmpty {
            let queue = ApplicationMusicQueue()
            queue.append(songArray)
            try await Player.shared.setQueue(queue)
        }
    }
    
    func addToQueue(_ item: MusicQueueItem, position: InsertPosition) async throws {
        let request = MusicCatalogResourceRequest<MusicKit.Song>(matching: \.id, equalTo: MusicItemID(item.id))
        if let song = try await request.response().items.first {
            switch position {
            case .next:
                await Player.shared.queue.insert(song, position: .next)
            case .last:
                await Player.shared.queue.insert(song, position: .tail)
            case .atIndex(let index):
                if index < currentQueue.count {
                    await Player.shared.queue.insert(song, position: .afterItem(currentQueue[index].id))
                } else {
                    await Player.shared.queue.insert(song, position: .tail)
                }
            }
            updateCurrentQueue()
        }
    }
    
    func removeFromQueue(at index: Int) {
        applicationMusicPlayer.queue.removeItem(at: index)
        updateCurrentQueue()
    }
    
    func clearQueue() {
        applicationMusicPlayer.queue.clear()
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
        updateCurrentQueue()
        updateNowPlaying()
        updatePlaybackState()
    }
}
