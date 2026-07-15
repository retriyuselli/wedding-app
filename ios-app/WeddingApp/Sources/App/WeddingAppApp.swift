import SwiftUI
import GoogleSignIn

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task { @MainActor in
            PushNotificationManager.shared.configure()
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            PushNotificationManager.shared.updateDeviceToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        #if DEBUG
        print("APNs registration failed: \(error.localizedDescription)")
        #endif
    }
}

@main
struct WeddingAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var session = SessionStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastActivated: Date?

    var body: some Scene {
        WindowGroup {
            RootView(session: session)
                .environmentObject(session)
                .modifier(AppLanguageModifier())
                .modifier(AppAppearanceModifier())
                // Outside appearance remounts so splash isn't discarded mid-animation.
                .splashScreenOverlay()
                .onAppear {
                    GoogleSignInService.shared.configureIfNeeded()
                }
                .onOpenURL { url in
                    _ = GoogleSignInService.shared.handle(url: url)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                let now = Date()
                if let lastActivated, now.timeIntervalSince(lastActivated) <= 300 {
                    return
                }
                lastActivated = now
                NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
                Task { @MainActor in
                    await PushNotificationManager.shared.syncDeviceTokenIfPossible()
                }
            }
        }
    }
}

extension Notification.Name {
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
    static let sessionExpired = Notification.Name("WeddingApp.sessionExpired")
    static let openMessages = Notification.Name("WeddingApp.openMessages")
}

private struct AppLanguageModifier: ViewModifier {
    @ObservedObject private var language = LanguageStore.shared

    func body(content: Content) -> some View {
        if LanguageFeature.isSelectionEnabled {
            content
                .id(language.selected.rawValue)
                .environment(\.locale, language.selected == .english ? Locale(identifier: "en_US") : Locale(identifier: "id_ID"))
        } else {
            content
                .environment(\.locale, Locale(identifier: "id_ID"))
        }
    }
}

private struct AppAppearanceModifier: ViewModifier {
    @ObservedObject private var appearance = AppearanceStore.shared

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(appearance.theme.preferredColorScheme)
            .id("appearance-\(appearance.colorPalette.rawValue)-\(appearance.theme.rawValue)-\(appearance.textSize.rawValue)")
    }
}
