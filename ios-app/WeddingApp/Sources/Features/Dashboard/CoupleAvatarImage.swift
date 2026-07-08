import SwiftUI

struct CoupleAvatarImage: View {
    var width: CGFloat = 168
    var height: CGFloat = 200

    var body: some View {
        Image("CouplePortrait")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(photoShape)
            .overlay {
                photoShape.stroke(AppTheme.gold.opacity(0.5), lineWidth: 1.2)
            }
    }

    private var photoShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 24,
            topTrailingRadius: 24,
            style: .continuous
        )
    }
}
