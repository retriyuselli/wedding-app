import SwiftUI

struct CoupleAvatarImage: View {
    var width: CGFloat = 168
    var height: CGFloat = 200
    var showsFloralBackdrop: Bool = false
    var cornerRadius: CGFloat = 24

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

            Image("CouplePortrait")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height, alignment: .center)
                .clipped()
                .clipShape(photoShape)
                .shadow(color: AppTheme.sageDark.opacity(0.18), radius: 18, y: 10)
                .shadow(color: AppTheme.gold.opacity(0.10), radius: 8, y: 4)
        }
        .frame(width: width, height: height, alignment: .center)
    }

    private var photoShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius * 0.55,
            bottomLeadingRadius: cornerRadius * 0.55,
            bottomTrailingRadius: cornerRadius,
            topTrailingRadius: cornerRadius,
            style: .continuous
        )
    }
}
