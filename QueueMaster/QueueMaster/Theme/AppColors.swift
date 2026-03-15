import SwiftUI

struct AppColors {
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let background = Color("Background")
    static let surface = Color("Surface")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let destructive = Color("Destructive")
    static let success = Color("Success")
    static let warning = Color("Warning")
    
    struct Light {
        static let primary = Color(hex: "007AFF")
        static let secondary = Color(hex: "5856D6")
        static let background = Color(hex: "F2F2F7")
        static let surface = Color(hex: "FFFFFF")
        static let textPrimary = Color(hex: "000000")
        static let textSecondary = Color(hex: "3C3C43").opacity(0.6)
        static let destructive = Color(hex: "FF3B30")
        static let success = Color(hex: "34C759")
        static let warning = Color(hex: "FF9500")
    }
    
    struct Dark {
        static let primary = Color(hex: "0A84FF")
        static let secondary = Color(hex: "5E5CE6")
        static let background = Color(hex: "000000")
        static let surface = Color(hex: "1C1C1E")
        static let textPrimary = Color(hex: "FFFFFF")
        static let textSecondary = Color(hex: "EBEBF5").opacity(0.6)
        static let destructive = Color(hex: "FF453A")
        static let success = Color(hex: "30D158")
        static let warning = Color(hex: "FF9F0A")
    }
    
    static func adaptive(_ light: Color, _ dark: Color) -> Color {
        return Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
