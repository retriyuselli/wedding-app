import SwiftUI

struct CoupleAvatarImage: View {
    let avatarUrl: String?
    var width: CGFloat = 168
    var height: CGFloat = 200

    var body: some View {
        Group {
            if let avatarUrl,
               let url = URL(string: avatarUrl),
               !avatarUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    case .empty:
                        placeholder
                            .overlay {
                                ProgressView()
                            }
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipShape(photoShape)
        .overlay {
            photoShape.stroke(AppTheme.gold.opacity(0.5), lineWidth: 1.2)
        }
    }

    private var placeholder: some View {
        Image("CouplePortrait")
            .resizable()
            .aspectRatio(contentMode: .fill)
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
