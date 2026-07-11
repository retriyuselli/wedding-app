import SwiftUI

struct RootView: View {
    @ObservedObject var session: SessionStore
    @State private var hasBootstrapped = false

    var body: some View {
        Group {
            if session.currentUser != nil {
                DashboardView()
                    .id(session.authRevision)
            } else {
                LoginView()
            }
        }
        .font(AppFont.regular(16))
        .task(priority: .utility) {
            await bootstrapIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired).receive(on: DispatchQueue.main)) { _ in
            session.clearSession()
        }
        #if DEBUG
        .onChange(of: session.currentUser?.id) { _, userId in
            print("[Root] currentUser changed -> \(userId.map(String.init) ?? "nil")")
        }
        #endif
    }

    @MainActor
    private func bootstrapIfNeeded() async {
        guard !hasBootstrapped else {
            return
        }

        hasBootstrapped = true

        #if DEBUG
        print("[Bootstrap] Starting background bootstrap")
        #endif

        await APIResolver.resolveIfNeeded()

        guard session.currentUser == nil else {
            #if DEBUG
            print("[Bootstrap] Skipped restore — user already authenticated")
            #endif
            return
        }

        await session.restoreSession(timeout: .seconds(3))

        #if DEBUG
        print("[Bootstrap] Finished — user=\(session.currentUser.map { String($0.id) } ?? "nil")")
        #endif
    }
}
