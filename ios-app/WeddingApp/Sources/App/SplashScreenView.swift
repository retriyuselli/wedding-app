import SwiftUI

/// Soft brand splash — interlocking rings meet, glow blooms, then title settles in.
/// Background matches the app theme via `LuxuryWeddingBackground`.
struct SplashScreenView: View {
    @State private var ringsApart = true
    @State private var ringsVisible = false
    @State private var titleVisible = false
    @State private var taglineVisible = false
    @State private var glowActive = false
    @State private var shimmer = false

    var body: some View {
        ZStack {
            LuxuryWeddingBackground(showsFloral: false)

            // Soft ambient orbs — atmosphere only, not the main gesture.
            ambientOrbs
                .opacity(ringsVisible ? 1 : 0)

            VStack(spacing: 22) {
                Spacer(minLength: 0)

                WeddingRingAnimation(
                    ringsApart: ringsApart,
                    glowActive: glowActive,
                    shimmer: shimmer
                )
                .frame(width: 120, height: 96)
                .opacity(ringsVisible ? 1 : 0)
                .scaleEffect(ringsVisible ? 1 : 0.82)

                VStack(spacing: 8) {
                    HStack(spacing: 7) {
                        Text(L10n.Auth.brandWedding)
                            .foregroundStyle(AppTheme.sageDark)
                        Text(L10n.Auth.brandApp)
                            .foregroundStyle(AppTheme.goldDark)
                    }
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .shadow(color: AppTheme.sageDark.opacity(0.10), radius: 8, y: 2)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 10)

                    Text(L10n.Dashboard.planTogether)
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(AppTheme.sageDark.opacity(0.72))
                        .opacity(taglineVisible ? 1 : 0)
                        .offset(y: taglineVisible ? 0 : 6)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onAppear { playEntrance() }
    }

    private var ambientOrbs: some View {
        ZStack {
            Circle()
                .fill(AppTheme.sage.opacity(0.14))
                .frame(width: 160, height: 160)
                .blur(radius: 36)
                .offset(x: -70, y: -90)
                .scaleEffect(glowActive ? 1.08 : 0.94)

            Circle()
                .fill(AppTheme.gold.opacity(0.12))
                .frame(width: 140, height: 140)
                .blur(radius: 32)
                .offset(x: 80, y: 40)
                .scaleEffect(glowActive ? 1.06 : 0.96)
        }
        .allowsHitTesting(false)
    }

    private func playEntrance() {
        withAnimation(.easeOut(duration: 0.35)) {
            ringsVisible = true
        }

        // Rings drift together — the main wedding gesture.
        withAnimation(.spring(response: 0.85, dampingFraction: 0.82).delay(0.12)) {
            ringsApart = false
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.55)) {
            glowActive = true
        }

        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true).delay(0.7)) {
            shimmer = true
        }

        withAnimation(.easeOut(duration: 0.55).delay(0.55)) {
            titleVisible = true
        }

        withAnimation(.easeOut(duration: 0.55).delay(0.85)) {
            taglineVisible = true
        }
    }
}

struct WeddingRingAnimation: View {
    var ringsApart: Bool
    var glowActive: Bool
    var shimmer: Bool
    /// Soft looping bloom behind the rings (option 1).
    var softPulse: Bool = true

    @State private var pulseExpanded = false

    private let ringSize: CGFloat = 54
    private let lineWidth: CGFloat = 4.2

    private var leftOffset: CGSize {
        ringsApart ? CGSize(width: -34, height: 8) : CGSize(width: -14, height: 3)
    }

    private var rightOffset: CGSize {
        ringsApart ? CGSize(width: 34, height: -8) : CGSize(width: 14, height: -3)
    }

    private var bloomScale: CGFloat {
        if ringsApart {
            return 0.92
        }
        if softPulse {
            return pulseExpanded ? 1.16 : 0.96
        }
        return glowActive ? 1.10 : 0.92
    }

    private var bloomOpacity: Double {
        if ringsApart { return 0.45 }
        if softPulse {
            return pulseExpanded ? 1.0 : 0.72
        }
        return 0.95
    }

    var body: some View {
        ZStack {
            // Bloom behind the join — soft pulse when interlocked.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.gold.opacity(glowActive ? 0.34 : 0.18),
                            AppTheme.sage.opacity(glowActive ? 0.18 : 0.09),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 58
                    )
                )
                .frame(width: 118, height: 118)
                .scaleEffect(bloomScale)
                .opacity(bloomOpacity)

            // Left ring — sage
            ring(color: AppTheme.sageDark, highlight: AppTheme.sage)
                .offset(leftOffset)
                .rotationEffect(.degrees(ringsApart ? -18 : (glowActive ? 5 : -4)))

            // Right ring — gold
            ring(color: AppTheme.goldDark, highlight: AppTheme.gold, shimmering: true)
                .offset(rightOffset)
                .rotationEffect(.degrees(ringsApart ? 18 : (glowActive ? -4 : 5)))

            // Overlap bridge so bands read as interlocked after they meet.
            if !ringsApart {
                ring(color: AppTheme.sageDark, highlight: AppTheme.sage, trim: 0.55...0.95)
                    .offset(leftOffset)
                    .rotationEffect(.degrees(glowActive ? 5 : -4))
                    .transition(.opacity)
            }
        }
        .onAppear {
            guard softPulse, !pulseExpanded else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseExpanded = true
            }
        }
    }

    private func ring(
        color: Color,
        highlight: Color,
        trim: ClosedRange<CGFloat>? = nil,
        shimmering: Bool = false
    ) -> some View {
        ZStack {
            if let trim {
                Circle()
                    .trim(from: trim.lowerBound, to: trim.upperBound)
                    .stroke(
                        AngularGradient(
                            colors: [highlight, color, highlight],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            } else {
                Circle()
                    .stroke(color.opacity(0.22), lineWidth: lineWidth + 2)

                Circle()
                    .stroke(
                        AngularGradient(
                            colors: shimmering
                                ? [
                                    highlight.opacity(shimmer ? 1 : 0.75),
                                    color,
                                    Color.white.opacity(shimmer ? 0.55 : 0.15),
                                    highlight.opacity(0.85),
                                    color,
                                ]
                                : [highlight, color, highlight.opacity(0.8), color],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                Circle()
                    .stroke(Color.white.opacity(0.32), lineWidth: 1)
                    .padding(3)
            }
        }
        .frame(width: ringSize, height: ringSize)
        .shadow(
            color: highlight.opacity(softPulse && pulseExpanded ? 0.38 : 0.30),
            radius: softPulse && pulseExpanded ? 9 : (glowActive ? 7 : 4),
            y: 1
        )
    }
}

struct SplashScreenOverlayModifier: ViewModifier {
    var visibleSeconds: Double = 3.8
    var fadeSeconds: Double = 0.55

    @State private var isVisible = true
    @State private var opacity: Double = 1

    func body(content: Content) -> some View {
        content
            .overlay {
                if isVisible {
                    SplashScreenView()
                        .opacity(opacity)
                        .allowsHitTesting(opacity > 0.05)
                        .transition(.opacity)
                        .zIndex(999)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(visibleSeconds))
                withAnimation(.easeOut(duration: fadeSeconds)) {
                    opacity = 0
                }
                try? await Task.sleep(for: .seconds(fadeSeconds))
                isVisible = false
            }
    }
}

extension View {
    func splashScreenOverlay(
        visibleSeconds: Double = 3.8,
        fadeSeconds: Double = 0.55
    ) -> some View {
        modifier(
            SplashScreenOverlayModifier(
                visibleSeconds: visibleSeconds,
                fadeSeconds: fadeSeconds
            )
        )
    }
}
