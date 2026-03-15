import SwiftUI
import MusicKit

@main
struct QueueMasterApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(colorScheme)
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView()
                }
                .onAppear {
                    checkOnboardingNeeded()
                }
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch settingsViewModel.darkModePreference {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    private func checkOnboardingNeeded() {
        let hasShown = UserDefaults.standard.bool(forKey: "hasShownOnboarding")
        if !hasShown {
            showOnboarding = true
        }
    }
}
