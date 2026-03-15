import SwiftUI

struct QueueItemCard: View {
    let item: MusicQueueItem
    let isPlaying: Bool
    let showDragHandle: Bool
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if showDragHandle {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }
            
            AsyncImage(url: item.artworkURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.secondary)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: 56, height: 56)
            .cornerRadius(AppCornerRadius.medium)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                    .fontWeight(isPlaying ? .semibold : .regular)
                    .foregroundColor(isPlaying ? .accentColor : primaryTextColor)
                    .lineLimit(1)
                
                Text(item.artistName)
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.accentColor)
                    .font(.caption)
            }
            
            if let duration = formatDuration(item.durationInSeconds) {
                Text(duration)
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
            }
        }
        .padding(.vertical, AppSpacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            if let onDelete = onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Remove from Queue", systemImage: "trash")
                }
            }
            
            Button {
                // Future: Add to playlist
            } label: {
                Label("Add to Playlist", systemImage: "plus.rectangle.on.folder")
            }
        }
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? AppColors.Dark.textPrimary : AppColors.Light.textPrimary
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? AppColors.Dark.textSecondary : AppColors.Light.textSecondary
    }
    
    private func formatDuration(_ seconds: Int) -> String? {
        guard seconds > 0 else { return nil }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct EmptyQueueView: View {
    let onSyncQueue: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Songs in Queue")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Sync with your Apple Music queue or add songs to get started.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Button(action: onSyncQueue) {
                Label("Sync Queue", systemImage: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct QueueHeaderView: View {
    let queueCount: Int
    let totalDuration: Int
    let onClear: () -> Void
    let onShuffle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(queueCount) songs")
                    .font(.headline)
                
                if totalDuration > 0 {
                    Text(formatTotalDuration(totalDuration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onShuffle) {
                Image(systemName: "shuffle")
            }
            .buttonStyle(.bordered)
            
            Button(role: .destructive, action: onClear) {
                Image(systemName: "trash")
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }
    
    private func formatTotalDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Text("Try Again")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
