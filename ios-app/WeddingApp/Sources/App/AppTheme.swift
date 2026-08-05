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

    /// Soft fill for circular icon buttons (contrasts with `iconOnChrome`).
    static var chrome: Color { color(\.surface) }

    /// Icon color on chrome / light button backgrounds.
    static var iconOnChrome: Color { color(\.sageDark) }

    /// Hairline / border that stays visible in dark mode (replaces raw Color.white).
    static var hairline: Color {
        Color(
            uiColor: UIColor { traits in
                // Midnight cards are solid white — need a dark edge, not a white wash.
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    return UIColor(white: 0, alpha: 0.10)
                }
                if prefersDark(traits: traits) {
                    return UIColor(white: 1, alpha: 0.22)
                }
                return UIColor(white: 1, alpha: 0.72)
            }
        )
    }

    /// Tab bar unselected item color with safe contrast.
    static var tabUnselected: Color {
        Color(
            uiColor: UIColor { traits in
                if prefersDark(traits: traits) {
                    return UIColor(white: 0.72, alpha: 1)
                }
                return UIColor(white: 0.42, alpha: 1)
            }
        )
    }

    /// Status / muted marker — readable on cream cards (light) and dark cards.
    static var statusMuted: Color {
        Color(
            uiColor: UIColor { traits in
                if prefersDark(traits: traits) {
                    return UIColor(white: 0.70, alpha: 1)
                }
                // Mid gray (not palette mist) so rings/dots stay visible on ivory surfaces.
                return UIColor(red: 0.62, green: 0.64, blue: 0.62, alpha: 1)
            }
        )
    }

    /// Primary title on glass cards. Light: sageDark. Dark: near-ivory (avoids washout on mid-tone glass).
    static var titleOnGlass: Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition.sageDark
                if prefersDark(traits: traits) {
                    return UIColor(red: 0.94, green: 0.95, blue: 0.92, alpha: 1)
                }
                let rgb = token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    /// Page titles drawn on `background` (e.g. Home/tab headers), not on white cards.
    /// Midnight uses pure white so text stays readable on the black stage.
    static var titleOnBackground: Color {
        Color(
            uiColor: UIColor { traits in
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    return UIColor.white
                }
                let token = AppearanceStore.currentPalette.definition.sageDark
                let rgb = prefersDark(traits: traits) ? token.dark : token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    /// Accent word/mark on page background (e.g. "App", taglines).
    static var accentOnBackground: Color {
        Color(
            uiColor: UIColor { traits in
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    // Bright lemon-gold for contrast on black.
                    return UIColor(red: 1.0, green: 0.86, blue: 0.32, alpha: 1)
                }
                let token = AppearanceStore.currentPalette.definition.gold
                let rgb = prefersDark(traits: traits) ? token.dark : token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    /// Softer supporting copy on page background.
    static var mutedOnBackground: Color {
        Color(
            uiColor: UIColor { traits in
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    // Pure white for welcome/tagline contrast on the black stage.
                    return UIColor.white
                }
                let token = AppearanceStore.currentPalette.definition.gold
                let rgb = prefersDark(traits: traits) ? token.dark : token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 0.85)
            }
        )
    }

    /// Soft ink for captions on glass. Light keeps the given opacity; dark uses an opaque brighter grey.
    static func inkMuted(_ opacity: CGFloat) -> Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition.ink
                if prefersDark(traits: traits) {
                    let brightness = min(0.92, 0.52 + opacity * 0.95)
                    return UIColor(white: brightness, alpha: 1)
                }
                let rgb = token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: opacity)
            }
        )
    }

    /// Soft sageDark. Light keeps opacity; dark stays bright enough on dark glass.
    static func sageMuted(_ opacity: CGFloat) -> Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition.sageDark
                if prefersDark(traits: traits) {
                    let alpha = min(1, 0.72 + opacity * 0.35)
                    return UIColor(red: 0.88, green: 0.92, blue: 0.86, alpha: alpha)
                }
                let rgb = token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: opacity)
            }
        )
    }

    /// Unselected filter-chip fill (white wash in light; subtle lift in dark).
    static var chipIdleFill: Color {
        Color(
            uiColor: UIColor { traits in
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    return UIColor(red: 0.90, green: 0.94, blue: 0.99, alpha: 1)
                }
                if prefersDark(traits: traits) {
                    return UIColor(white: 1, alpha: 0.16)
                }
                return UIColor(white: 1, alpha: 0.7)
            }
        )
    }

    /// Nested row fill inside glass sections.
    static var nestedGlassFill: Color {
        Color(
            uiColor: UIColor { traits in
                // Midnight: solid white cards on the black stage (translucent white becomes muddy grey).
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    let rgb = AppearanceStore.currentPalette.definition.surface.light
                    return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
                }
                if prefersDark(traits: traits) {
                    return UIColor(white: 1, alpha: 0.10)
                }
                return UIColor(white: 1, alpha: 0.62)
            }
        )
    }

    /// Soft pad behind wedding-event / section glyphs. Dark uses a deep sage so icons stay visible.
    static var iconChipFill: Color {
        Color(
            uiColor: UIColor { traits in
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    return UIColor(red: 0.88, green: 0.93, blue: 0.99, alpha: 1)
                }
                if prefersDark(traits: traits) {
                    return UIColor(red: 0.20, green: 0.28, blue: 0.23, alpha: 1)
                }
                return UIColor(white: 1, alpha: 0.72)
            }
        )
    }

    static var iconChipStroke: Color {
        Color(
            uiColor: UIColor { traits in
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    return UIColor(white: 0, alpha: 0.08)
                }
                if prefersDark(traits: traits) {
                    return UIColor(white: 1, alpha: 0.20)
                }
                return UIColor(white: 1, alpha: 0.65)
            }
        )
    }

    /// Glyph color on `iconChipFill`. Light: sageDark. Dark: bright sage on deep pad.
    static var iconOnChip: Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition.sageDark
                if prefersDark(traits: traits) {
                    return UIColor(red: 0.78, green: 0.90, blue: 0.80, alpha: 1)
                }
                let rgb = token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    /// Empty progress track that remains visible on dark glass cards.
    static var progressTrack: Color {
        Color(
            uiColor: UIColor { traits in
                let sage = AppearanceStore.currentPalette.definition.sage
                if prefersDark(traits: traits) {
                    return UIColor(white: 1, alpha: 0.18)
                }
                let rgb = sage.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 0.14)
            }
        )
    }

    /// Caption under section headers (e.g. “0 of 77 tasks”). Light: soft ink; dark: soft gold.
    static var captionOnGlass: Color {
        Color(
            uiColor: UIColor { traits in
                if prefersDark(traits: traits) {
                    return UIColor(red: 0.86, green: 0.78, blue: 0.58, alpha: 1)
                }
                let ink = AppearanceStore.currentPalette.definition.ink.light
                // Midnight white cards need slightly stronger caption ink for readability.
                let alpha: CGFloat = AppearanceStore.currentPalette.prefersLightContentChrome ? 0.72 : 0.62
                return UIColor(red: ink.0, green: ink.1, blue: ink.2, alpha: alpha)
            }
        )
    }

    /// Secondary labels on solid white / lightSage cards (Budget metrics, chips, empty-state captions).
    static var captionOnLightSurface: Color {
        Color(
            uiColor: UIColor { _ in
                let ink = AppearanceStore.currentPalette.definition.ink.light
                // Keep captions clearly readable on white / pale sage — 0.55 washed out too easily.
                let alpha: CGFloat = AppearanceStore.currentPalette.prefersLightContentChrome ? 0.78 : 0.72
                return UIColor(red: ink.0, green: ink.1, blue: ink.2, alpha: alpha)
            }
        )
    }

    /// Deep sage for text sitting on light/ivory pills (selected tabs). Always uses light-token sageDark.
    static var labelOnLightSurface: Color {
        Color(
            uiColor: UIColor { _ in
                let rgb = AppearanceStore.currentPalette.definition.sageDark.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    /// Gold accent on light pills (selected tab counts). Always readable on white/lightSage.
    static var accentOnLightSurface: Color {
        goldOnLightSurface
    }

    /// Darker gold for amounts/labels sitting on white or lightSage cards (readable vs pale `gold`).
    static var goldOnLightSurface: Color {
        Color(
            uiColor: UIColor { _ in
                // Midnight gold tokens stay bright for the dark stage; on white cards they wash out.
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    return UIColor(red: 0.52, green: 0.38, blue: 0.06, alpha: 1)
                }
                let rgb = AppearanceStore.currentPalette.definition.goldDark.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    /// Primary CTA label — white when enabled; ink when disabled (avoids white-on-pale fills).
    static func primaryActionForeground(enabled: Bool) -> Color {
        enabled ? Color.white : ink.opacity(0.55)
    }

    /// Primary CTA fill — brand when enabled; soft mist when disabled.
    static func primaryActionFill(enabled: Bool) -> Color {
        enabled ? sageDark : mist
    }

    /// Darker brand end-stop so white label text stays crisp on gradients in dark mode.
    static var brandGradientEnd: Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition.sageDark
                if prefersDark(traits: traits) {
                    return UIColor(red: 0.26, green: 0.40, blue: 0.30, alpha: 1)
                }
                let rgb = token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    /// Donut / ring empty track — stronger in dark so empty RSVP charts stay visible.
    static var donutTrack: Color {
        Color(
            uiColor: UIColor { traits in
                let sage = AppearanceStore.currentPalette.definition.sage
                if prefersDark(traits: traits) {
                    return UIColor(white: 1, alpha: 0.28)
                }
                let rgb = sage.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 0.28)
            }
        )
    }

    /// Soft selected-tab / toolbar pill fill.
    static var selectedChipFill: Color {
        Color(
            uiColor: UIColor { traits in
                // Midnight: opaque soft pad — translucent white turns muddy grey on black.
                if AppearanceStore.currentPalette.prefersLightContentChrome {
                    let rgb = AppearanceStore.currentPalette.definition.lightSage.light
                    return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
                }
                if prefersDark(traits: traits) {
                    return UIColor(white: 0.92, alpha: 0.92)
                }
                return UIColor(white: 1, alpha: 0.78)
            }
        )
    }

    /// Rich quote-card gradient stops — always use light-palette brand tones so white copy stays readable in dark mode.
    static var quoteGradientLeading: Color {
        Color(
            uiColor: UIColor { _ in
                let rgb = AppearanceStore.currentPalette.definition.sage.light
                return UIColor(red: rgb.0 * 0.82, green: rgb.1 * 0.82, blue: rgb.2 * 0.82, alpha: 1)
            }
        )
    }

    static var quoteGradientMid: Color {
        Color(
            uiColor: UIColor { _ in
                let rgb = AppearanceStore.currentPalette.definition.sageDark.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    static var quoteGradientTrailing: Color {
        Color(
            uiColor: UIColor { _ in
                let rgb = AppearanceStore.currentPalette.definition.goldDark.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 0.92)
            }
        )
    }

    /// Soft gold accent on deep quote cards (quotation mark / laurels).
    static var quoteAccent: Color {
        Color(
            uiColor: UIColor { _ in
                let rgb = AppearanceStore.currentPalette.definition.gold.light
                return UIColor(red: min(1, rgb.0 + 0.08), green: min(1, rgb.1 + 0.06), blue: min(1, rgb.2 + 0.04), alpha: 1)
            }
        )
    }

    /// Stronger muted fill for selected “Not Attending” chips (white label stays readable).
    static var statusMutedSelected: Color {
        Color(
            uiColor: UIColor { traits in
                if prefersDark(traits: traits) {
                    return UIColor(white: 0.40, alpha: 1)
                }
                return UIColor(red: 0.52, green: 0.54, blue: 0.52, alpha: 1)
            }
        )
    }

    /// Fill behind filled checkmark (dark circle so white check stays crisp in both themes).
    static var statusDoneFill: Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition.sageDark
                if prefersDark(traits: traits) {
                    return UIColor(red: 0.32, green: 0.48, blue: 0.38, alpha: 1)
                }
                let rgb = token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    private static func color(_ keyPath: KeyPath<ColorPaletteTokens, ThemeRGB>) -> Color {
        Color(
            uiColor: UIColor { traits in
                let token = AppearanceStore.currentPalette.definition[keyPath: keyPath]
                // Do not trust traits from .ultraThinMaterial — they often report .dark
                // inside light sheets and make TextField text resolve to near-white.
                let rgb = prefersDark(traits: traits) ? token.dark : token.light
                return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            }
        )
    }

    private static func prefersDark(traits: UITraitCollection) -> Bool {
        // Midnight keeps white-card / dark-stage chrome regardless of appearance mode.
        if AppearanceStore.currentPalette.prefersLightContentChrome {
            return false
        }

        switch AppearanceStore.currentTheme {
        case .light:
            return false
        case .dark:
            return true
        case .system:
            // UIColor providers often run off the main thread — never touch
            // UIApplication/UIWindow here. Prefer the SwiftUI-fed cache so we
            // also avoid bogus .dark traits from .ultraThinMaterial.
            if let cached = cachedSystemInterfaceStyle {
                return cached == .dark
            }
            return traits.userInterfaceStyle == .dark
        }
    }

    /// App-level interface style from SwiftUI `colorScheme` (main-thread updates only).
    nonisolated(unsafe) private static var cachedSystemInterfaceStyle: UIUserInterfaceStyle?

    static func updateCachedInterfaceStyle(from colorScheme: ColorScheme) {
        cachedSystemInterfaceStyle = colorScheme == .dark ? .dark : .light
    }
}

struct PremiumGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 32

    func body(content: Content) -> some View {
        content
            .background {
                // Solid fill only — avoid .ultraThinMaterial (expensive during scroll).
                // Midnight: solid white on the black stage (cream/lightSage wash turns muddy).
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        AppearanceStore.currentPalette.prefersLightContentChrome
                            ? AnyShapeStyle(AppTheme.surface)
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        AppTheme.surface,
                                        AppTheme.cream.opacity(0.92),
                                        AppTheme.lightSage.opacity(0.78),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 8, y: 4)
    }
}

/// Lightweight chrome for dense scrolling rows (no material, no soft shadow).
struct PremiumListRowModifier: ViewModifier {
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        AppearanceStore.currentPalette.prefersLightContentChrome
                            ? AppTheme.surface
                            : AppTheme.nestedGlassFill
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.hairline.opacity(0.7), lineWidth: 1)
            }
    }
}

extension View {
    func premiumGlassCard(cornerRadius: CGFloat = 32) -> some View {
        modifier(PremiumGlassCardModifier(cornerRadius: cornerRadius))
    }

    func premiumListRow(cornerRadius: CGFloat = 18) -> some View {
        modifier(PremiumListRowModifier(cornerRadius: cornerRadius))
    }
}
