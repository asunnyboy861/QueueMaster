import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .queue
    
    enum Tab {
        case queue
        case history
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            QueueEditorView()
                .tabItem {
                    Label("Queue", systemImage: "music.note.list")
                }
                .tag(Tab.queue)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    MainTabView()
}
