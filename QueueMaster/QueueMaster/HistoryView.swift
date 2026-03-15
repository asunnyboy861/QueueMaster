import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showClearConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading history...")
                } else if viewModel.queueHistory.isEmpty {
                    emptyHistoryView
                } else {
                    historyList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.exportHistory()
                        } label: {
                            Label("Export History", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                viewModel.loadHistory()
            }
            .confirmationDialog("Clear History", isPresented: $showClearConfirmation, titleVisibility: .visible) {
                Button("Clear All History", role: .destructive) {
                    viewModel.deleteAllHistory()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all queue history and statistics.")
            }
            .sheet(isPresented: $viewModel.showExportSheet) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.Dark.background : AppColors.Light.background
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No History Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your queue snapshots will appear here once you start managing your queue.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
        }
        .padding()
    }
    
    private var historyList: some View {
        List {
            statisticsSection
            
            ForEach(viewModel.queueHistory) { snapshot in
                SnapshotCardView(
                    snapshot: snapshot,
                    formattedDate: viewModel.getFormattedDate(snapshot.timestamp),
                    sourceLabel: viewModel.getSourceLabel(snapshot.source),
                    onRestore: {
                        viewModel.restoreSnapshot(snapshot)
                    },
                    onDelete: {
                        viewModel.deleteSnapshot(snapshot)
                    }
                )
                .listRowBackground(backgroundColor)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var statisticsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Statistics")
                    .font(.headline)
                
                HStack(spacing: AppSpacing.lg) {
                    StatCard(title: "Queue Edits", value: "\(viewModel.playStatistics.totalQueueEdits)", icon: "pencil.circle")
                    StatCard(title: "Restores", value: "\(viewModel.playStatistics.totalRestores)", icon: "arrow.counterclockwise.circle")
                }
                
                HStack(spacing: AppSpacing.lg) {
                    StatCard(title: "Most Active", value: viewModel.playStatistics.mostEditedTimeOfDay, icon: "clock")
                    StatCard(title: "Avg Queue", value: "\(viewModel.playStatistics.favoriteQueueLength)", icon: "music.note.list")
                }
            }
            .listRowBackground(backgroundColor)
        }
    }
}

struct SnapshotCardView: View {
    let snapshot: QueueSnapshot
    let formattedDate: String
    let sourceLabel: String
    let onRestore: () -> Void
    let onDelete: () -> Void
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(sourceLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(snapshot.items.count) songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if isExpanded || snapshot.items.count <= 3 {
                ForEach(snapshot.items.prefix(5)) { item in
                    HStack {
                        Text(item.title)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text(item.artistName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if snapshot.items.count > 5 {
                    Text("+ \(snapshot.items.count - 5) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if snapshot.items.count > 3 {
                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    Text("Show \(snapshot.items.count) songs")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            
            HStack {
                Button { onRestore() } label: {
                    Label("Restore", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderedProminent)
                .buttonStyle(.plain)
                
                Button(role: .destructive) { onDelete() } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(AppCornerRadius.medium)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HistoryView()
}
