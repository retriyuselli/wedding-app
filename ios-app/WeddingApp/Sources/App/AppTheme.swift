import SwiftUI
import UIKit

enum AppTheme {
    static var navy: Color { color(\.navy) }
    static var cardBackground: Color { color(\.cardBackground) }
    static var peach: Color { color(\.peach) }
    static var peachDark: Color { color(\.peachDark) }
    static var softPeach: Color { color(\.softPeach) }
    static var background: Color { color(\.background) }
    static var surface: Color { color(\.surface) }
    static var ink: Color { color(\.ink) }
    static var mist: Color { color(\.mist) }
    static var plum: Color { color(\.plum) }
    static var sage: Color { color(\.sage) }
    static var lightSage: Color { color(\.lightSage) }
    static var sageDark: Color { color(\.sageDark) }
    static var gold: Color { color(\.gold) }
    static var goldDark: Color { color(\.goldDark) }
    static var green: Color { color(\.green) }
    static var brown: Color { color(\.brown) }
    static var cream: Color { color(\.cream) }

    private static func color(_ keyPath: KeyPath<ColorPaletteTokens, ThemeRGB>) -> Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition[keyPath: keyPath]
                let rgb = traits.userInterfaceStyle == .dark ? token.dark : token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }
}
