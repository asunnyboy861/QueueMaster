import SwiftUI
import MusicKit

struct QueueEditorView: View {
    @StateObject private var viewModel = QueueViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var isEditing: Bool = false
    @State private var showingClearConfirmation: Bool = false
    @State private var selectedItems: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading queue...")
                } else if viewModel.currentQueue.isEmpty {
                    EmptyQueueView {
                        viewModel.syncWithAppleMusic()
                    }
                } else {
                    queueList
                }
            }
            .navigationTitle("Queue")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.canUndo || viewModel.canRedo {
                        Menu {
                            if viewModel.canUndo {
                                Button {
                                    viewModel.undo()
                                } label: {
                                    Label("Undo", systemImage: "arrow.uturn.backward")
                                }
                            }
                            if viewModel.canRedo {
                                Button {
                                    viewModel.redo()
                                } label: {
                                    Label("Redo", systemImage: "arrow.uturn.forward")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            viewModel.syncWithAppleMusic()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        
                        EditButton()
                    }
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .onAppear {
                checkAuthorizationAndLoad()
            }
            .alert("Restore Queue?", isPresented: $viewModel.showRestoreAlert) {
                Button("Restore") {
                    viewModel.restoreFromPending()
                }
                Button("Dismiss", role: .cancel) {
                    viewModel.dismissRestoreAlert()
                }
            } message: {
                if let snapshot = viewModel.pendingSnapshot {
                    Text("Your previous queue had \(snapshot.items.count) songs. Would you like to restore it?")
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .confirmationDialog("Clear Queue", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
                Button("Clear Queue", role: .destructive) {
                    viewModel.clearQueue()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to clear the queue? This action can be undone.")
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.Dark.background : AppColors.Light.background
    }
    
    private var queueList: some View {
        VStack(spacing: 0) {
            QueueHeaderView(
                queueCount: viewModel.currentQueue.count,
                totalDuration: viewModel.totalDuration,
                onClear: {
                    showingClearConfirmation = true
                },
                onShuffle: {
                    // Shuffle functionality
                }
            )
            
            List {
                ForEach(Array(viewModel.currentQueue.enumerated()), id: \.element.id) { index, item in
                    QueueItemCard(
                        item: item,
                        isPlaying: index == viewModel.currentIndex,
                        showDragHandle: isEditing,
                        onTap: {
                            Task {
                                await viewModel.playItem(at: index)
                            }
                        },
                        onDelete: isEditing ? {
                            viewModel.removeItem(at: index)
                        } : nil
                    )
                    .listRowBackground(backgroundColor)
                    .listRowSeparatorTint(.secondary.opacity(0.3))
                }
                .onMove { source, destination in
                    viewModel.moveItem(from: source, to: destination)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.removeItem(at: index)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            MiniPlayerView(
                currentItem: viewModel.currentItem,
                isPlaying: viewModel.isPlaying,
                playbackTime: viewModel.playbackTime,
                onPlayPause: { viewModel.togglePlayPause() },
                onNext: { viewModel.next() },
                onSeek: { time in viewModel.seek(to: time) }
            )
        }
    }
    
    private func checkAuthorizationAndLoad() {
        Task {
            if viewModel.authorizationStatus == .notDetermined {
                await viewModel.requestAuthorization()
            } else if viewModel.authorizationStatus == .authorized {
                await viewModel.loadQueue()
            }
        }
    }
}

struct MiniPlayerView: View {
    let currentItem: MusicQueueItem?
    let isPlaying: Bool
    let playbackTime: TimeInterval
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onSeek: (TimeInterval) -> Void
    
    @State private var isExpanded: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedPlayer
            } else {
                collapsedMiniPlayer
            }
        }
        .frame(height: isExpanded ? 300 : 64)
        .background(.ultraThinMaterial)
        .animation(.spring(response: 0.3), value: isExpanded)
    }
    
    private var collapsedMiniPlayer: some View {
        HStack(spacing: AppSpacing.md) {
            if let item = currentItem {
                AsyncImage(url: item.artworkURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 48, height: 48)
                .cornerRadius(6)
                .onTapGesture {
                    isExpanded = true
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(item.artistName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                Button(action: onNext) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            } else {
                Text("No track playing")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }
    
    private var expandedPlayer: some View {
        VStack(spacing: AppSpacing.lg) {
            if let item = currentItem {
                HStack {
                    Spacer()
                    Button {
                        isExpanded = false
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                
                AsyncImage(url: item.artworkURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 250, height: 250)
                .cornerRadius(AppCornerRadius.large)
                .shadow(radius: 20)
                
                VStack(spacing: AppSpacing.xs) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(item.artistName)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: AppSpacing.sm) {
                    Slider(
                        value: Binding(
                            get: { playbackTime },
                            set: { onSeek($0) }
                        ),
                        in: 0...Double(item.durationInSeconds)
                    )
                    .tint(.accentColor)
                    
                    HStack {
                        Text(formatTime(playbackTime))
                        Spacer()
                        Text(formatTime(Double(item.durationInSeconds)))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                HStack(spacing: AppSpacing.xxl) {
                    Button {
                        // Previous
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onPlayPause) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onNext) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    QueueEditorView()
}
