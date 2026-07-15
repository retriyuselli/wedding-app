import SwiftUI

struct RootView: View {
    @ObservedObject var session: SessionStore
    @State private var hasBootstrapped = false
    @State private var onboardingPhase: OnboardingPhase = .checking

    private enum OnboardingPhase { 
          case checking
        case required
        case ready
    }

    var body: some View {
        Group {
            if session.currentUser != nil {
                switch onboardingPhase {
                case .checking:
                    ZStack {
                        LuxuryWeddingBackground()
                        ProgressView()
                            .tint(AppTheme.sageDark)
                    }
                case .required:
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onboardingPhase = .ready
                        }
                    }
                case .ready:
                    DashboardView()
                        .id(session.authRevision)
                }
            } else {
                LoginView()
            }
        }
        .font(AppFont.regular(16))
        .task(priority: .utility) {
            await bootstrapIfNeeded()
        }
        .task(id: session.currentUser?.id) {
            await resolveOnboardingIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired).receive(on: DispatchQueue.main)) { _ in
            session.clearSession()
            onboardingPhase = .checking
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

    @MainActor
    private func resolveOnboardingIfNeeded() async {
        guard session.currentUser != nil else {
            onboardingPhase = .checking
            return
        }

        onboardingPhase = .checking

        do {
            let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request("wedding-info")
            onboardingPhase = OnboardingGate.needsOnboarding(info: envelope.data) ? .required : .ready
        } catch {
            // If the check fails, let the user into the app rather than blocking login.
            onboardingPhase = .ready
        }
    }
}
