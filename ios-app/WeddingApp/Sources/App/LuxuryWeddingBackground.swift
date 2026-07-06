import SwiftUI

struct LuxuryWeddingBackground: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.96, blue: 0.95),
                    Color(red: 0.96, green: 0.95, blue: 0.94),
                    Color(red: 1.00, green: 1.00, blue: 1.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.68),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 40,
                endRadius: 520
            )
            .blendMode(.screen)

            Image("FloralHeader")
                .resizable()
                .scaledToFit()
                .frame(width: 330, height: 330)
                .opacity(0.75)
                .offset(x: 78, y: 108)
                .allowsHitTesting(false)

            LinearGradient(
                colors: [
                    Color.clear,
                    Color(red: 0.97, green: 0.96, blue: 0.95).opacity(0.36)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}
