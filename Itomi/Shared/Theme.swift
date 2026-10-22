// Pro color themes: the counter card, bars and buttons follow the picked color (plum is the default)

import SwiftUI
import UIKit

enum Theme: String, CaseIterable, Identifiable {
    case plum, rose, terracotta, sage, denim, charcoal

    var id: String {
        return rawValue
    }

    // e.g. "Terracotta"
    var name: String {
        return rawValue.capitalized
    }

    // Each color has a lighter version for dark mode, like plum does
    var color: Color {
        switch self {
        case .plum:
            return Color.accent
        case .rose:
            return Theme.makeColor(light: 0x94485F, dark: 0xD08A9E)
        case .terracotta:
            return Theme.makeColor(light: 0x9A4A2E, dark: 0xD48F72)
        case .sage:
            return Theme.makeColor(light: 0x4E6A52, dark: 0x93B497)
        case .denim:
            return Theme.makeColor(light: 0x3D5A78, dark: 0x8AA9CB)
        case .charcoal:
            return Theme.makeColor(light: 0x3A3A40, dark: 0xB4B4BE)
        }
    }

    // The matching home screen icon in the asset catalog (nil means the main plum icon)
    var iconName: String? {
        if self == .plum {
            return nil
        }
        return "AppIcon-\(name)"
    }

    // A color that switches between two hex values for light and dark mode
    static func makeColor(light: Int, dark: Int) -> Color {
        let uiColor = UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return Theme.uiColor(hex: dark)
            }
            return Theme.uiColor(hex: light)
        }
        return Color(uiColor: uiColor)
    }

    static func uiColor(hex: Int) -> UIColor {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

// The theme color, handed down from the app to every screen that follows the theme
extension EnvironmentValues {
    @Entry var themeColor: Color = Color.accent
}
