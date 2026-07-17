import SwiftUI

struct CoupleAvatarImage: View {
    var photoURL: URL? = nil
    var width: CGFloat = 118
    var height: CGFloat = 156
    var showsFloralBackdrop: Bool = false
    var cornerRadius: CGFloat = 0

    private var portraitShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: portraitCornerRadius, style: .continuous)
    }

    private var portraitCornerRadius: CGFloat {
        if cornerRadius > 0 { return cornerRadius }
        return min(width, height) * 0.42
    }

    private var portraitWidth: CGFloat {
        min(width * 0.94, 124)
    }

    private var portraitHeight: CGFloat {
        min(height * 0.94, 164)
    }

    var body: some View {
        ZStack {
            if showsFloralBackdrop {
                Image("FloralHeader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 1.35, height: width * 1.35)
                    .opacity(0.42)
                    .blur(radius: 0.5)
                    .offset(x: width * 0.12, y: height * 0.08)
                    .allowsHitTesting(false)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.lightSage.opacity(0.55),
                                AppTheme.cream.opacity(0.1),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: width * 0.72
                        )
                    )
                    .frame(width: width * 1.15, height: width * 1.15)
                    .offset(y: height * 0.06)
                    .allowsHitTesting(false)
            }

            if let photoURL {
                couplePhoto(url: photoURL)
            } else {
                framedPortrait { ringsPlaceholderContent }
                    .accessibilityHidden(true)
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }

    private func couplePhoto(url: URL) -> some View {
        framedPortrait {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ringsPlaceholderContent
                case .empty:
                    ZStack {
                        portraitShape.fill(AppTheme.iconChipFill)
                        ProgressView()
                            .tint(AppTheme.sageDark)
                    }
                @unknown default:
                    ringsPlaceholderContent
                }
            }
        }
        .accessibilityLabel(L10n.More.couple)
    }

    private func framedPortrait<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: portraitWidth, height: portraitHeight)
            .clipShape(portraitShape)
            .overlay {
                // Soft edge vignette — keeps bright photos quieter in the card.
                portraitShape
                    .fill(
                        RadialGradient(
                            colors: [
                                .clear,
                                .clear,
                                AppTheme.sageDark.opacity(0.12),
                            ],
                            center: .center,
                            startRadius: portraitWidth * 0.30,
                            endRadius: portraitHeight * 0.74
                        )
                    )
                    .allowsHitTesting(false)
            }
            .overlay {
                portraitShape
                    .stroke(AppTheme.cream.opacity(0.95), lineWidth: 2.5)
                    .padding(2.5)
            }
            .overlay {
                portraitShape
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.gold.opacity(0.78),
                                AppTheme.sage.opacity(0.42),
                                AppTheme.gold.opacity(0.62),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.6
                    )
            }
            .shadow(color: AppTheme.sageDark.opacity(0.16), radius: 16, y: 10)
            .shadow(color: AppTheme.gold.opacity(0.10), radius: 8, y: 4)
    }

    private var ringsPlaceholderContent: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.cream.opacity(0.95),
                    AppTheme.lightSage.opacity(0.55),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            WeddingRingAnimation(
                ringsApart: false,
                glowActive: true,
                shimmer: true
            )
            .frame(width: portraitWidth * 0.78, height: portraitHeight * 0.48)
        }
    }
}
