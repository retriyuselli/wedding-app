import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var hasRestoredSession = false

    var body: some View {
        Group {
            if !hasRestoredSession {
                SplashView()
            } else if session.currentUser != nil {
                DashboardView()
            } else {
                LoginView()
            }
        }
        .font(AppFont.regular(16))
        .task {
            await BudgetCategoriesStore.shared.loadIfNeeded()
            await session.restoreSession()
            hasRestoredSession = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired).receive(on: DispatchQueue.main)) { _ in
            session.clearSession()
            hasRestoredSession = true
        }
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            VStack(spacing: 20) {
                HStack(spacing: 6) {
                    Text("Wedding")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.sageDark)
                    Text("App")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.gold)
                }

                ProgressView()
                    .tint(AppTheme.sageDark)
                    .scaleEffect(1.2)
            }
        }
    }
}
