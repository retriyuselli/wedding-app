import SwiftUI

private struct StatusBarBlur: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            GeometryReader { proxy in
                let topInset = proxy.safeAreaInsets.top
                VStack(spacing: 0) {
                    ZStack {
                        Color(red: 0.97, green: 0.96, blue: 0.95).opacity(0.82)
                        Rectangle().fill(.ultraThinMaterial)
                    }
                    .frame(height: topInset)
                    LinearGradient(
                        colors: [.white.opacity(0.48), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 14)
                }
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

extension View {
    func statusBarBlur() -> some View {
        modifier(StatusBarBlur())
    }
}
