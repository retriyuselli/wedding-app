import SwiftUI
import UIKit

/// App text faces — only **Poppins** (body/UI) and **SF Serif / New York** (titles).
struct AppFont {
    // MARK: - Poppins

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

    // MARK: - SF Serif (New York)

    static func serifRegular(_ size: CGFloat) -> Font {
        .system(size: size * AppearanceStore.currentTextScale, weight: .regular, design: .serif)
    }

    static func serifMedium(_ size: CGFloat) -> Font {
        .system(size: size * AppearanceStore.currentTextScale, weight: .medium, design: .serif)
    }

    static func serifSemibold(_ size: CGFloat) -> Font {
        .system(size: size * AppearanceStore.currentTextScale, weight: .semibold, design: .serif)
    }

    static func serifBold(_ size: CGFloat) -> Font {
        .system(size: size * AppearanceStore.currentTextScale, weight: .bold, design: .serif)
    }

    /// Countdown digits on Home — follows Appearance → Countdown preference (Poppins or SF Serif only).
    static func countdown(_ size: CGFloat) -> Font {
        AppearanceStore.currentCountdownFont.font(size: size)
    }

    // MARK: - UIKit (navigation chrome)

    static func serifUIFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size * AppearanceStore.currentTextScale, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.serif) else { return base }
        return UIFont(descriptor: descriptor, size: base.pointSize)
    }

    static func poppinsUIFont(name: String, size: CGFloat) -> UIFont {
        let scaled = size * AppearanceStore.currentTextScale
        return UIFont(name: name, size: scaled) ?? .systemFont(ofSize: scaled)
    }

    /// Large + inline navigation titles use SF Serif so system `navigationTitle` matches page headers.
    /// Midnight uses white title color so large titles stay readable on the black stage.
    static func applyNavigationTitleFonts() {
        let large = serifUIFont(size: 34, weight: .bold)
        let inline = serifUIFont(size: 17, weight: .semibold)
        let titleColor: UIColor = {
            if AppearanceStore.currentPalette.prefersLightContentChrome {
                return .white
            }
            let rgb = AppearanceStore.currentPalette.definition.sageDark.light
            return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
        }()

        let attrsLarge: [NSAttributedString.Key: Any] = [
            .font: large,
            .foregroundColor: titleColor,
        ]
        let attrsInline: [NSAttributedString.Key: Any] = [
            .font: inline,
            .foregroundColor: titleColor,
        ]

        func patch(_ appearance: UINavigationBarAppearance) {
            appearance.largeTitleTextAttributes = attrsLarge
            appearance.titleTextAttributes = attrsInline
        }

        let nav = UINavigationBar.appearance()
        patch(nav.standardAppearance)
        if let compact = nav.compactAppearance {
            patch(compact)
        } else {
            let compact = UINavigationBarAppearance()
            compact.configureWithDefaultBackground()
            patch(compact)
            nav.compactAppearance = compact
        }

        if let scrollEdge = nav.scrollEdgeAppearance {
            patch(scrollEdge)
        } else {
            let scrollEdge = UINavigationBarAppearance()
            scrollEdge.configureWithTransparentBackground()
            patch(scrollEdge)
            nav.scrollEdgeAppearance = scrollEdge
        }

        if let compactScroll = nav.compactScrollEdgeAppearance {
            patch(compactScroll)
        }

        nav.largeTitleTextAttributes = attrsLarge
        nav.titleTextAttributes = attrsInline
    }
}
