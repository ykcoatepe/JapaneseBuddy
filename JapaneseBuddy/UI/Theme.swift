import SwiftUI
import UIKit

// Theme tokens and helpers
enum Theme {
    enum Spacing {
        static let xsmall: CGFloat = 6
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum CornerRadius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum Shadow {
        static let card = ShadowStyle(radius: 8, y: 2, opacity: 0.08)
        struct ShadowStyle { let radius: CGFloat; let y: CGFloat; let opacity: Double }
    }
}

extension Color {
    // Accent comes from Assets.xcassets (AccentColor)
    static let washi = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let wasabi = Color(hue: 0.27, saturation: 0.45, brightness: 0.75)
    static let cardBackground = Color(.secondarySystemBackground)
}

extension View {
    func cardShadow(_ style: Theme.Shadow.ShadowStyle = Theme.Shadow.card) -> some View {
        shadow(color: .black.opacity(style.opacity), radius: style.radius, x: 0, y: style.y)
    }
}

enum Typography {
    static func title(_ text: String) -> some View { Text(text).font(.largeTitle).bold() }
    static func header(_ text: String) -> some View { Text(text).font(.title2).bold() }
    static func label(_ text: String) -> some View { Text(text).font(.subheadline).foregroundStyle(.secondary) }
}
