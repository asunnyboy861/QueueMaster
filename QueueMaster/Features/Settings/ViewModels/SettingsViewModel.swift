import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var autoSaveEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoSaveEnabled, forKey: Keys.autoSave)
        }
    }
    
    @Published var autoSaveInterval: Int {
        didSet {
            UserDefaults.standard.set(autoSaveInterval, forKey: Keys.autoSaveInterval)
        }
    }
    
    @Published var queueProtectionEnabled: Bool {
        didSet {
            UserDefaults.standard.set(queueProtectionEnabled, forKey: Keys.queueProtection)
        }
    }
    
    @Published var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedback)
        }
    }
    
    @Published var darkModePreference: DarkModePreference {
        didSet {
            UserDefaults.standard.set(darkModePreference.rawValue, forKey: Keys.darkMode)
        }
    }
    
    @Published var showNotifications: Bool {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: Keys.notifications)
        }
    }
    
    enum DarkModePreference: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }
    
    private struct Keys {
        static let autoSave = "autoSaveEnabled"
        static let autoSaveInterval = "autoSaveInterval"
        static let queueProtection = "queueProtectionEnabled"
        static let hapticFeedback = "hapticFeedbackEnabled"
        static let darkMode = "darkModePreference"
        static let notifications = "showNotifications"
    }
    
    init() {
        self.autoSaveEnabled = UserDefaults.standard.bool(forKey: Keys.autoSave)
        self.autoSaveInterval = UserDefaults.standard.integer(forKey: Keys.autoSaveInterval)
        if self.autoSaveInterval == 0 {
            self.autoSaveInterval = 30
        }
        self.queueProtectionEnabled = UserDefaults.standard.object(forKey: Keys.queueProtection) as? Bool ?? true
        self.hapticFeedbackEnabled = UserDefaults.standard.object(forKey: Keys.hapticFeedback) as? Bool ?? true
        
        if let darkModeRaw = UserDefaults.standard.string(forKey: Keys.darkMode) {
            self.darkModePreference = DarkModePreference(rawValue: darkModeRaw) ?? .system
        } else {
            self.darkModePreference = .system
        }
        
        self.showNotifications = UserDefaults.standard.bool(forKey: Keys.notifications)
    }
    
    func resetToDefaults() {
        autoSaveEnabled = false
        autoSaveInterval = 30
        queueProtectionEnabled = true
        hapticFeedbackEnabled = true
        darkModePreference = .system
        showNotifications = false
    }
    
    func clearAllData() {
        HistoryManager.shared.deleteAllSnapshots()
        UserDefaults.standard.removeObject(forKey: Keys.autoSave)
        UserDefaults.standard.removeObject(forKey: Keys.autoSaveInterval)
        UserDefaults.standard.removeObject(forKey: Keys.queueProtection)
        UserDefaults.standard.removeObject(forKey: Keys.hapticFeedback)
        UserDefaults.standard.removeObject(forKey: Keys.darkMode)
        UserDefaults.standard.removeObject(forKey: Keys.notifications)
        
        resetToDefaults()
    }
}
