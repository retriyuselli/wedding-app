import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.currentUser != nil {
                DashboardView()
            } else {
                LoginView()
            }
        }
        .font(AppFont.regular(16))
        .task {
            await session.restoreSession()
        }
    }
}
