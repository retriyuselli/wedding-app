import SwiftUI

struct AppFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("Poppins-Regular", size: size * AppearanceStore.currentTextScale, relativeTo: .body)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Poppins-Medium", size: size * AppearanceStore.currentTextScale, relativeTo: .body)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("Poppins-SemiBold", size: size * AppearanceStore.currentTextScale, relativeTo: .body)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("Poppins-Bold", size: size * AppearanceStore.currentTextScale, relativeTo: .body)
    }

    /// Stencil display face for countdown digits (closest free alternative to iPhone Lock Screen Stencil).
    static func stencil(_ size: CGFloat) -> Font {
        .custom("SairaStencilOne-Regular", size: size * AppearanceStore.currentTextScale, relativeTo: .largeTitle)
    }

    /// Countdown digits on Home — follows Appearance → Countdown preference.
    static func countdown(_ size: CGFloat) -> Font {
        AppearanceStore.currentCountdownFont.font(size: size)
    }
}
