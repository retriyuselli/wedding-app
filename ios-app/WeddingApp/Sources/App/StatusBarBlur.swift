import SwiftUI

private struct StatusBarBlur: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    private var wash: Color { AppTheme.background }

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            GeometryReader { proxy in
                let topInset = proxy.safeAreaInsets.top
                VStack(spacing: 0) {
                    ZStack {
                        wash.opacity(0.98)
                        Rectangle().fill(.thickMaterial)
                        Rectangle().fill(.regularMaterial)
                        wash.opacity(0.55)
                    }
                    .frame(height: topInset)

                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(.thinMaterial)
                            .mask(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.35), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        LinearGradient(
                            colors: [
                                wash.opacity(0.9),
                                wash.opacity(0.45),
                                wash.opacity(0.12),
                                .clear,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .frame(height: 32)
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
