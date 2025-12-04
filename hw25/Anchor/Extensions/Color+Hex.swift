import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - App Theme
struct Theme {
    // MARK: - Colors
    struct Colors {
        // Primary calming greens
        static let primary = Color(hex: "4A8C6F") // Sage green
        static let secondary = Color(hex: "8FB8A3") // Light sage
        static let accent = Color(hex: "2D5A48") // Deep green
        
        // Backgrounds
        static let background = Color(hex: "F7F9F8") // Off-white/grayish green
        static let surface = Color.white.opacity(0.9)
        static let glass = Color.white.opacity(0.7)
        
        // Text
        static let textPrimary = Color(hex: "1A2C24") // Dark green/black
        static let textSecondary = Color(hex: "5C7A6F") // Muted green
        
        // Status
        static let active = Color(hex: "4CAF50")
        static let inactive = Color(hex: "9E9E9E")
        static let error = Color(hex: "E57373")
        
        static let cardShadow = Color.black.opacity(0.05) // Moved here
        
        // Gradients
        static let calmingGradient = LinearGradient(
            colors: [
                Color(hex: "F1F8F4"),
                Color(hex: "E0F2E3"),
                Color(hex: "F1F8F4")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let primaryGradient = LinearGradient(
            colors: [primary, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Layout
    struct Layout {
        static let cornerRadius: CGFloat = 24
        static let padding: CGFloat = 20
        // static let cardShadow = Color.black.opacity(0.05) // Removed from here
        static let cardShadowRadius: CGFloat = 10
    }
    
    // MARK: - Typography
    struct Typography {
        static func header(size: CGFloat = 32) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func subheader(size: CGFloat = 18) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        
        static func body(size: CGFloat = 16) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }
        
        static func caption(size: CGFloat = 14) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
    }
}

// MARK: - View Modifiers
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .fill(Theme.Colors.surface)
                    .shadow(color: Theme.Colors.cardShadow, radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}
