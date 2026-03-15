import SwiftUI

struct QueueEditorView: View {
    @StateObject private var viewModel = QueueViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var isEditing: Bool = false
    @State private var showingClearConfirmation: Bool = false
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedItems: Set<String> = []
    @State private var isSelectionMode: Bool = false
    
    // Filtered queue based on search
    private var filteredQueue: [MusicQueueItem] {
        if searchText.isEmpty {
            return viewModel.currentQueue
        }
        
        return viewModel.currentQueue.filter { item in
            item.title.localizedCaseInsensitiveContains(searchText) ||
            item.artistName.localizedCaseInsensitiveContains(searchText) ||
            (item.albumTitle?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    private var hasSelectedItems: Bool {
        !selectedItems.isEmpty
    }
    
    // Toggle selection for batch operations
    private func toggleSelection(for item: MusicQueueItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    // Delete all selected items
    private func deleteSelectedItems() {
        for itemId in selectedItems {
            if let index = viewModel.currentQueue.firstIndex(where: { $0.id == itemId }) {
                viewModel.removeItem(at: index)
            }
        }
        selectedItems.removeAll()
        isSelectionMode = false
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search field
                if isSearching {
                    searchField
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Queue list
                queueList
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
                        // Batch delete button
                        if hasSelectedItems {
                            Button(role: .destructive) {
                                deleteSelectedItems()
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        
                        // Search button
                        Button {
                            withAnimation {
                                isSearching.toggle()
                                if !isSearching {
                                    searchText = ""
                                }
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        
                        // Sync button
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
    
    // Search field
    private var searchField: some View {
        HStack {
            TextField("Search in queue", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.Dark.background : AppColors.Light.background
    }
    
    private var queueList: some View {
        VStack(spacing: 0) {
            QueueHeaderView(
                queueCount: filteredQueue.count,
                totalDuration: viewModel.totalDuration,
                onClear: {
                    showingClearConfirmation = true
                },
                onShuffle: {}
            )
            
            List {
                ForEach(Array(filteredQueue.enumerated()), id: \.element.id) { index, item in
                    queueItemRow(for: item, at: index)
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
    
    @ViewBuilder
    private func queueItemRow(for item: MusicQueueItem, at index: Int) -> some View {
        QueueItemCard(
            item: item,
            isPlaying: item.id == viewModel.currentItem?.id,
            showDragHandle: isEditing,
            onTap: {
                if isSelectionMode {
                    toggleSelection(for: item)
                } else {
                    Task {
                        await viewModel.playItem(item)
                    }
                }
            },
            onDelete: isEditing ? {
                if let originalIndex = viewModel.currentQueue.firstIndex(where: { $0.id == item.id }) {
                    viewModel.removeItem(at: originalIndex)
                }
            } : nil,
            isSelected: selectedItems.contains(item.id)
        )
        .listRowBackground(backgroundColor)
        .onLongPressGesture {
            withAnimation {
                isSelectionMode = true
                toggleSelection(for: item)
            }
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
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "music.note").foregroundColor(.secondary))
                }
                .frame(width: 48, height: 48)
                .cornerRadius(6)
                .onTapGesture { isExpanded = true }
                
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
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "music.note").font(.system(size: 60)).foregroundColor(.secondary))
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
                        in: 0...Double(max(item.durationInSeconds, 1))
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
                    Button {} label: {
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
