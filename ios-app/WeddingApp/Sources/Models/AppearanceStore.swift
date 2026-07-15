import Foundation
import SwiftUI

enum AppAppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var title: String {
        switch self {
        case .system: return L10n.Settings.themeSystem
        case .light: return L10n.Settings.themeLight
        case .dark: return L10n.Settings.themeDark
        }
    }

    var subtitle: String {
        switch self {
        case .system: return L10n.Settings.themeSystemSub
        case .light: return L10n.Settings.themeLightSub
        case .dark: return L10n.Settings.themeDarkSub
        }
    }
}

/// Alias lama agar pemanggilan `AppThemePreference` tetap aman saat migrasi.
typealias AppThemePreference = AppAppearanceMode

enum AppColorPalette: String, CaseIterable, Identifiable {
    case sage
    case blush
    case champagne
    case ocean

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sage: return L10n.Settings.paletteSage
        case .blush: return L10n.Settings.paletteBlush
        case .champagne: return L10n.Settings.paletteChampagne
        case .ocean: return L10n.Settings.paletteOcean
        }
    }

    var subtitle: String {
        switch self {
        case .sage: return L10n.Settings.paletteSageSub
        case .blush: return L10n.Settings.paletteBlushSub
        case .champagne: return L10n.Settings.paletteChampagneSub
        case .ocean: return L10n.Settings.paletteOceanSub
        }
    }

    /// Swatch untuk preview di Settings (urutan: accent, accentDark, gold, surface).
    var previewColors: [Color] {
        let tokens = definition
        return [
            Color(rgb: tokens.sage.light),
            Color(rgb: tokens.sageDark.light),
            Color(rgb: tokens.gold.light),
            Color(rgb: tokens.surface.light),
        ]
    }

    var definition: ColorPaletteTokens {
        switch self {
        case .sage: return .sage
        case .blush: return .blush
        case .champagne: return .champagne
        case .ocean: return .ocean
        }
    }
}

struct ThemeRGB {
    let light: (CGFloat, CGFloat, CGFloat)
    let dark: (CGFloat, CGFloat, CGFloat)

    init(light: (CGFloat, CGFloat, CGFloat), dark: (CGFloat, CGFloat, CGFloat)) {
        self.light = light
        self.dark = dark
    }
}

struct ColorPaletteTokens {
    let navy: ThemeRGB
    let cardBackground: ThemeRGB
    let peach: ThemeRGB
    let peachDark: ThemeRGB
    let softPeach: ThemeRGB
    let background: ThemeRGB
    let surface: ThemeRGB
    let ink: ThemeRGB
    let mist: ThemeRGB
    let plum: ThemeRGB
    let sage: ThemeRGB
    let lightSage: ThemeRGB
    let sageDark: ThemeRGB
    let gold: ThemeRGB
    let goldDark: ThemeRGB
    let green: ThemeRGB
    let brown: ThemeRGB
    let cream: ThemeRGB
}

extension ColorPaletteTokens {
    static let sage = ColorPaletteTokens(
        navy: ThemeRGB(light: (0.03, 0.10, 0.21), dark: (0.78, 0.84, 0.92)),
        cardBackground: ThemeRGB(light: (0.97, 0.97, 0.96), dark: (0.18, 0.20, 0.18)),
        peach: ThemeRGB(light: (0.93, 0.66, 0.55), dark: (0.90, 0.62, 0.52)),
        peachDark: ThemeRGB(light: (0.74, 0.39, 0.29), dark: (0.92, 0.62, 0.52)),
        softPeach: ThemeRGB(light: (0.97, 0.90, 0.87), dark: (0.28, 0.22, 0.20)),
        background: ThemeRGB(light: (0.97, 0.95, 0.90), dark: (0.10, 0.11, 0.10)),
        surface: ThemeRGB(light: (1.00, 0.98, 0.93), dark: (0.16, 0.18, 0.16)),
        ink: ThemeRGB(light: (0.14, 0.18, 0.18), dark: (0.93, 0.93, 0.90)),
        mist: ThemeRGB(light: (0.91, 0.90, 0.86), dark: (0.28, 0.30, 0.28)),
        plum: ThemeRGB(light: (0.43, 0.55, 0.45), dark: (0.58, 0.70, 0.58)),
        sage: ThemeRGB(light: (0.54, 0.65, 0.54), dark: (0.58, 0.70, 0.58)),
        lightSage: ThemeRGB(light: (0.91, 0.93, 0.90), dark: (0.22, 0.26, 0.22)),
        sageDark: ThemeRGB(light: (0.22, 0.34, 0.27), dark: (0.78, 0.88, 0.80)),
        gold: ThemeRGB(light: (0.76, 0.59, 0.28), dark: (0.88, 0.72, 0.40)),
        goldDark: ThemeRGB(light: (0.59, 0.42, 0.14), dark: (0.92, 0.78, 0.48)),
        green: ThemeRGB(light: (0.43, 0.55, 0.45), dark: (0.58, 0.70, 0.58)),
        brown: ThemeRGB(light: (0.59, 0.45, 0.30), dark: (0.82, 0.68, 0.50)),
        cream: ThemeRGB(light: (0.88, 0.80, 0.62), dark: (0.34, 0.30, 0.22))
    )

    static let blush = ColorPaletteTokens(
        navy: ThemeRGB(light: (0.22, 0.10, 0.16), dark: (0.94, 0.84, 0.88)),
        cardBackground: ThemeRGB(light: (0.98, 0.96, 0.96), dark: (0.20, 0.16, 0.17)),
        peach: ThemeRGB(light: (0.94, 0.68, 0.66), dark: (0.92, 0.64, 0.62)),
        peachDark: ThemeRGB(light: (0.78, 0.40, 0.42), dark: (0.94, 0.66, 0.66)),
        softPeach: ThemeRGB(light: (0.98, 0.90, 0.90), dark: (0.30, 0.20, 0.22)),
        background: ThemeRGB(light: (0.98, 0.95, 0.94), dark: (0.12, 0.09, 0.10)),
        surface: ThemeRGB(light: (1.00, 0.98, 0.97), dark: (0.19, 0.15, 0.16)),
        ink: ThemeRGB(light: (0.22, 0.14, 0.16), dark: (0.96, 0.92, 0.92)),
        mist: ThemeRGB(light: (0.94, 0.89, 0.89), dark: (0.32, 0.26, 0.28)),
        plum: ThemeRGB(light: (0.72, 0.46, 0.50), dark: (0.84, 0.60, 0.64)),
        sage: ThemeRGB(light: (0.78, 0.52, 0.55), dark: (0.86, 0.64, 0.66)),
        lightSage: ThemeRGB(light: (0.96, 0.90, 0.91), dark: (0.28, 0.20, 0.22)),
        sageDark: ThemeRGB(light: (0.50, 0.26, 0.30), dark: (0.94, 0.82, 0.84)),
        gold: ThemeRGB(light: (0.80, 0.56, 0.40), dark: (0.90, 0.70, 0.52)),
        goldDark: ThemeRGB(light: (0.62, 0.38, 0.24), dark: (0.94, 0.78, 0.62)),
        green: ThemeRGB(light: (0.72, 0.46, 0.50), dark: (0.84, 0.60, 0.64)),
        brown: ThemeRGB(light: (0.62, 0.42, 0.36), dark: (0.84, 0.66, 0.58)),
        cream: ThemeRGB(light: (0.92, 0.80, 0.76), dark: (0.36, 0.26, 0.26))
    )

    static let champagne = ColorPaletteTokens(
        navy: ThemeRGB(light: (0.18, 0.12, 0.06), dark: (0.94, 0.88, 0.78)),
        cardBackground: ThemeRGB(light: (0.98, 0.96, 0.92), dark: (0.20, 0.18, 0.14)),
        peach: ThemeRGB(light: (0.92, 0.72, 0.52), dark: (0.90, 0.68, 0.48)),
        peachDark: ThemeRGB(light: (0.74, 0.48, 0.28), dark: (0.92, 0.72, 0.48)),
        softPeach: ThemeRGB(light: (0.98, 0.93, 0.86), dark: (0.30, 0.24, 0.18)),
        background: ThemeRGB(light: (0.98, 0.96, 0.91), dark: (0.12, 0.10, 0.08)),
        surface: ThemeRGB(light: (1.00, 0.99, 0.95), dark: (0.19, 0.17, 0.13)),
        ink: ThemeRGB(light: (0.20, 0.16, 0.10), dark: (0.96, 0.93, 0.88)),
        mist: ThemeRGB(light: (0.93, 0.90, 0.84), dark: (0.32, 0.28, 0.22)),
        plum: ThemeRGB(light: (0.68, 0.56, 0.38), dark: (0.82, 0.72, 0.52)),
        sage: ThemeRGB(light: (0.72, 0.62, 0.45), dark: (0.82, 0.72, 0.52)),
        lightSage: ThemeRGB(light: (0.95, 0.92, 0.86), dark: (0.28, 0.24, 0.18)),
        sageDark: ThemeRGB(light: (0.40, 0.30, 0.16), dark: (0.94, 0.88, 0.74)),
        gold: ThemeRGB(light: (0.82, 0.68, 0.32), dark: (0.92, 0.78, 0.42)),
        goldDark: ThemeRGB(light: (0.62, 0.46, 0.16), dark: (0.94, 0.84, 0.52)),
        green: ThemeRGB(light: (0.68, 0.56, 0.38), dark: (0.82, 0.72, 0.52)),
        brown: ThemeRGB(light: (0.62, 0.48, 0.30), dark: (0.86, 0.72, 0.50)),
        cream: ThemeRGB(light: (0.92, 0.84, 0.64), dark: (0.38, 0.32, 0.20))
    )

    static let ocean = ColorPaletteTokens(
        navy: ThemeRGB(light: (0.08, 0.14, 0.22), dark: (0.82, 0.88, 0.94)),
        cardBackground: ThemeRGB(light: (0.96, 0.97, 0.98), dark: (0.16, 0.18, 0.20)),
        peach: ThemeRGB(light: (0.78, 0.68, 0.58), dark: (0.86, 0.74, 0.62)),
        peachDark: ThemeRGB(light: (0.58, 0.44, 0.34), dark: (0.88, 0.74, 0.60)),
        softPeach: ThemeRGB(light: (0.93, 0.92, 0.90), dark: (0.22, 0.24, 0.26)),
        background: ThemeRGB(light: (0.95, 0.96, 0.97), dark: (0.09, 0.11, 0.13)),
        surface: ThemeRGB(light: (0.98, 0.99, 1.00), dark: (0.15, 0.18, 0.20)),
        ink: ThemeRGB(light: (0.12, 0.16, 0.20), dark: (0.92, 0.94, 0.96)),
        mist: ThemeRGB(light: (0.88, 0.91, 0.93), dark: (0.26, 0.30, 0.34)),
        plum: ThemeRGB(light: (0.42, 0.56, 0.62), dark: (0.58, 0.72, 0.78)),
        sage: ThemeRGB(light: (0.48, 0.60, 0.66), dark: (0.58, 0.72, 0.78)),
        lightSage: ThemeRGB(light: (0.90, 0.93, 0.94), dark: (0.20, 0.24, 0.28)),
        sageDark: ThemeRGB(light: (0.20, 0.34, 0.40), dark: (0.80, 0.90, 0.94)),
        gold: ThemeRGB(light: (0.72, 0.60, 0.38), dark: (0.88, 0.74, 0.46)),
        goldDark: ThemeRGB(light: (0.52, 0.40, 0.20), dark: (0.92, 0.80, 0.54)),
        green: ThemeRGB(light: (0.42, 0.56, 0.62), dark: (0.58, 0.72, 0.78)),
        brown: ThemeRGB(light: (0.48, 0.44, 0.36), dark: (0.78, 0.72, 0.60)),
        cream: ThemeRGB(light: (0.82, 0.84, 0.78), dark: (0.30, 0.32, 0.30))
    )
}

enum AppTextSizePreference: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var scale: CGFloat {
        switch self {
        case .small: return 0.90
        case .medium: return 1.00
        case .large: return 1.12
        }
    }

    var title: String {
        switch self {
        case .small: return L10n.Settings.textSizeSmall
        case .medium: return L10n.Settings.textSizeMedium
        case .large: return L10n.Settings.textSizeLarge
        }
    }

    var subtitle: String {
        switch self {
        case .small: return L10n.Settings.textSizeSmallSub
        case .medium: return L10n.Settings.textSizeMediumSub
        case .large: return L10n.Settings.textSizeLargeSub
        }
    }

    var previewSize: CGFloat {
        15 * scale
    }
}

enum AppCountdownFontPreference: String, CaseIterable, Identifiable {
    case stencil
    case poppins
    case rounded
    case serif

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stencil: return L10n.Settings.countdownFontStencil
        case .poppins: return L10n.Settings.countdownFontPoppins
        case .rounded: return L10n.Settings.countdownFontRounded
        case .serif: return L10n.Settings.countdownFontSerif
        }
    }

    var subtitle: String {
        switch self {
        case .stencil: return L10n.Settings.countdownFontStencilSub
        case .poppins: return L10n.Settings.countdownFontPoppinsSub
        case .rounded: return L10n.Settings.countdownFontRoundedSub
        case .serif: return L10n.Settings.countdownFontSerifSub
        }
    }

    func font(size: CGFloat) -> Font {
        let scaled = size * AppearanceStore.currentTextScale
        switch self {
        case .stencil:
            return .custom("SairaStencilOne-Regular", size: scaled, relativeTo: .largeTitle)
        case .poppins:
            return .custom("Poppins-Bold", size: scaled, relativeTo: .largeTitle)
        case .rounded:
            return .system(size: scaled, weight: .bold, design: .rounded)
        case .serif:
            return .system(size: scaled, weight: .semibold, design: .serif)
        }
    }
}

@MainActor
final class AppearanceStore: ObservableObject {
    static let shared = AppearanceStore()

    /// Dibaca dari `AppFont` tanpa hop MainActor.
    nonisolated(unsafe) static var currentTextScale: CGFloat = 1.0
    /// Dibaca dari `AppTheme` / background tanpa hop MainActor.
    nonisolated(unsafe) static var currentPalette: AppColorPalette = .sage
    /// Dibaca dari `AppTheme` agar warna tidak ikut trait flip dari material.
    nonisolated(unsafe) static var currentTheme: AppAppearanceMode = .system
    /// Dibaca dari `AppFont.countdown` tanpa hop MainActor.
    nonisolated(unsafe) static var currentCountdownFont: AppCountdownFontPreference = .stencil

    @Published private(set) var theme: AppAppearanceMode
    @Published private(set) var colorPalette: AppColorPalette
    @Published private(set) var textSize: AppTextSizePreference
    @Published private(set) var countdownFont: AppCountdownFontPreference

    private let themeKey = "app_theme_preference"
    private let paletteKey = "app_color_palette"
    private let textSizeKey = "app_text_size_preference"
    private let countdownFontKey = "app_countdown_font_preference"

    var textScale: CGFloat { textSize.scale }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: themeKey),
           let value = AppAppearanceMode(rawValue: raw) {
            theme = value
        } else {
            theme = .system
        }

        if let raw = UserDefaults.standard.string(forKey: paletteKey),
           let value = AppColorPalette(rawValue: raw) {
            colorPalette = value
        } else {
            colorPalette = .sage
        }

        if let raw = UserDefaults.standard.string(forKey: textSizeKey),
           let value = AppTextSizePreference(rawValue: raw) {
            textSize = value
        } else {
            textSize = .medium
        }

        if let raw = UserDefaults.standard.string(forKey: countdownFontKey),
           let value = AppCountdownFontPreference(rawValue: raw) {
            countdownFont = value
        } else {
            countdownFont = .stencil
        }

        Self.currentTextScale = textSize.scale
        Self.currentPalette = colorPalette
        Self.currentTheme = theme
        Self.currentCountdownFont = countdownFont
    }

    func selectTheme(_ preference: AppAppearanceMode) {
        guard theme != preference else { return }
        theme = preference
        Self.currentTheme = preference
        UserDefaults.standard.set(preference.rawValue, forKey: themeKey)
    }

    func selectColorPalette(_ palette: AppColorPalette) {
        guard colorPalette != palette else { return }
        colorPalette = palette
        Self.currentPalette = palette
        UserDefaults.standard.set(palette.rawValue, forKey: paletteKey)
    }

    func selectTextSize(_ preference: AppTextSizePreference) {
        guard textSize != preference else { return }
        textSize = preference
        Self.currentTextScale = preference.scale
        UserDefaults.standard.set(preference.rawValue, forKey: textSizeKey)
    }

    func selectCountdownFont(_ preference: AppCountdownFontPreference) {
        guard countdownFont != preference else { return }
        countdownFont = preference
        Self.currentCountdownFont = preference
        UserDefaults.standard.set(preference.rawValue, forKey: countdownFontKey)
    }
}

extension Color {
    init(rgb: (CGFloat, CGFloat, CGFloat), opacity: CGFloat = 1) {
        self.init(red: rgb.0, green: rgb.1, blue: rgb.2, opacity: opacity)
    }
}
