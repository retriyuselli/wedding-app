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
            Color("SplashBackground")
                .ignoresSafeArea()

            Image("SplashScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}
