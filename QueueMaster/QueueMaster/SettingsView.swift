import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showResetConfirmation: Bool = false
    @State private var showClearDataConfirmation: Bool = false
    @State private var showContactSupport: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                List {
                    queueProtectionSection
                    generalSection
                    appearanceSection
                    dataSection
                    aboutSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Reset Settings", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset to Defaults", role: .destructive) {
                    viewModel.resetToDefaults()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all settings to their default values.")
            }
            .confirmationDialog("Clear All Data", isPresented: $showClearDataConfirmation, titleVisibility: .visible) {
                Button("Clear All Data", role: .destructive) {
                    viewModel.clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your queue history and statistics.")
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.Dark.background : AppColors.Light.background
    }
    
    private var queueProtectionSection: some View {
        Section {
            Toggle(isOn: $viewModel.queueProtectionEnabled) {
                Label("Queue Protection", systemImage: "shield")
            }
            
            Toggle(isOn: $viewModel.autoSaveEnabled) {
                Label("Auto-Save Queue", systemImage: "clock.arrow.circlepath")
            }
            
            if viewModel.autoSaveEnabled {
                Picker(selection: $viewModel.autoSaveInterval) {
                    Text("15 seconds").tag(15)
                    Text("30 seconds").tag(30)
                    Text("1 minute").tag(60)
                    Text("5 minutes").tag(300)
                } label: {
                    Label("Auto-Save Interval", systemImage: "timer")
                }
            }
        } header: {
            Text("Queue Protection")
        } footer: {
            Text("Queue protection helps prevent accidental loss of your carefully curated queue.")
        }
    }
    
    private var generalSection: some View {
        Section("General") {
            Toggle(isOn: $viewModel.hapticFeedbackEnabled) {
                Label("Haptic Feedback", systemImage: "hand.tap")
            }
            
            Toggle(isOn: $viewModel.showNotifications) {
                Label("Notifications", systemImage: "bell")
            }
        }
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker(selection: $viewModel.darkModePreference) {
                ForEach(SettingsViewModel.DarkModePreference.allCases, id: \.self) { preference in
                    Text(preference.rawValue).tag(preference)
                }
            } label: {
                Label("Theme", systemImage: "paintbrush")
            }
        }
    }
    
    private var dataSection: some View {
        Section("Data") {
            Button {
                showResetConfirmation = true
            } label: {
                Label("Reset Settings", systemImage: "arrow.counterclockwise")
            }
            .foregroundColor(.primary)
            
            Button(role: .destructive) {
                showClearDataConfirmation = true
            } label: {
                Label("Clear All Data", systemImage: "trash")
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            Button {
                showContactSupport = true
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
            .foregroundColor(.primary)
            
            Link(destination: URL(string: "https://queuemaster-support.vercel.app")!) {
                Label("Help & Support", systemImage: "questionmark.circle")
            }
            
            Link(destination: URL(string: "https://queuemaster-pricacy.vercel.app")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
        }
    }
}

#Preview {
    SettingsView()
}
