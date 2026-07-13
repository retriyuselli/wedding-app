import SwiftUI

struct LuxuryWeddingBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var appearance = AppearanceStore.shared

    var showsFloral = false

    private var isDark: Bool { colorScheme == .dark }

    private var tokens: ColorPaletteTokens {
        appearance.colorPalette.definition
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: isDark
                    ? [
                        Color(rgb: tokens.background.dark),
                        Color(rgb: tokens.surface.dark),
                        Color(rgb: tokens.background.dark),
                    ]
                    : [
                        Color(rgb: tokens.background.light),
                        Color(rgb: tokens.lightSage.light),
                        Color(rgb: tokens.surface.light),
                    ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    (isDark ? Color.white.opacity(0.08) : Color.white.opacity(0.68)),
                    Color.clear,
                ],
                center: .topLeading,
                startRadius: 40,
                endRadius: 520
            )
            .blendMode(isDark ? .plusLighter : .screen)

            if showsFloral {
                Image("FloralHeader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330, height: 330)
                    .opacity(isDark ? 0.22 : 0.75)
                    .offset(x: 78, y: 108)
                    .allowsHitTesting(false)
            }

            LinearGradient(
                colors: [
                    Color.clear,
                    Color(rgb: isDark ? tokens.background.dark : tokens.background.light)
                        .opacity(isDark ? 0.5 : 0.36),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .id(appearance.colorPalette.rawValue)
    }
}
