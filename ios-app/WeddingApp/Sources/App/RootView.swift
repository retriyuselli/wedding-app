import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var isAppReady = false
    @State private var splashOpacity = 1.0
    @State private var showSplashOverlay = true

    private let splashFadeDuration = 0.5
    private let minimumSplashDuration: Duration = .milliseconds(800)
    private let bootstrapTimeout: Duration = .seconds(10)

    var body: some View {
        ZStack {
            mainContent
                .opacity(isAppReady ? 1 : 0)

            if showSplashOverlay {
                SplashView()
                    .opacity(splashOpacity)
                    .allowsHitTesting(splashOpacity > 0.05)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .font(AppFont.regular(16))
        .task {
            await bootstrapApp()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired).receive(on: DispatchQueue.main)) { _ in
            session.clearSession()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if session.currentUser != nil {
            DashboardView()
        } else {
            LoginView()
        }
    }

    private func bootstrapApp() async {
        let startedAt = ContinuousClock.now

        await loadStartupData()

        await finishSplashTransition(since: startedAt)
    }

    private func loadStartupData() async {
        await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                await BudgetCategoriesStore.shared.loadIfNeeded()
                return true
            }

            group.addTask {
                await session.restoreSession()
                return true
            }

            group.addTask {
                try? await Task.sleep(for: bootstrapTimeout)
                return false
            }

            var completedLoads = 0

            while completedLoads < 2 {
                guard let finished = await group.next() else {
                    break
                }

                if finished {
                    completedLoads += 1
                    continue
                }

                break
            }

            group.cancelAll()
        }
    }

    @MainActor
    private func finishSplashTransition(since startedAt: ContinuousClock.Instant) async {
        let elapsed = startedAt.duration(to: .now)
        if elapsed < minimumSplashDuration {
            try? await Task.sleep(for: minimumSplashDuration - elapsed)
        }

        withAnimation(.easeInOut(duration: splashFadeDuration)) {
            isAppReady = true
            splashOpacity = 0
        }

        try? await Task.sleep(for: .milliseconds(Int(splashFadeDuration * 1_000) + 50))
        showSplashOverlay = false
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            Color("SplashBackground")
                .ignoresSafeArea()

            Image("SplashScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}
