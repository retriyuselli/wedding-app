import GoogleSignIn
import UIKit

enum GoogleSignInError: LocalizedError {
    case notConfigured
    case missingPresenter
    case missingIdToken
    case cancelled

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Google Sign-In belum dikonfigurasi. Isi GIDClientID di Info.plist."
        case .missingPresenter:
            return "Tidak dapat membuka layar login Google."
        case .missingIdToken:
            return "Token Google tidak tersedia. Coba lagi."
        case .cancelled:
            return "Login Google dibatalkan."
        }
    }
}

@MainActor
final class GoogleSignInService {
    static let shared = GoogleSignInService()

    private var isConfigured = false

    private init() {}

    func configureIfNeeded() {
        guard !isConfigured else {
            return
        }

        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
              !clientID.isEmpty,
              !clientID.contains("REPLACE_WITH") else {
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        isConfigured = true
    }

    var isAvailable: Bool {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            return false
        }

        return !clientID.isEmpty && !clientID.contains("REPLACE_WITH")
    }

    func signIn() async throws -> String {
        configureIfNeeded()

        guard isConfigured else {
            throw GoogleSignInError.notConfigured
        }

        guard let presenter = topViewController() else {
            throw GoogleSignInError.missingPresenter
        }

        let result: GIDSignInResult
        do {
            result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
        } catch {
            if (error as NSError).code == GIDSignInError.canceled.rawValue {
                throw GoogleSignInError.cancelled
            }

            throw error
        }

        guard let idToken = result.user.idToken?.tokenString else {
            throw GoogleSignInError.missingIdToken
        }

        return idToken
    }

    func handle(url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let resolvedBase = base ?? keyWindowRootViewController()

        if let navigationController = resolvedBase as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }

        if let tabController = resolvedBase as? UITabBarController {
            return topViewController(base: tabController.selectedViewController)
        }

        if let presented = resolvedBase?.presentedViewController {
            return topViewController(base: presented)
        }

        return resolvedBase
    }

    private func keyWindowRootViewController() -> UIViewController? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else {
                continue
            }

            for window in windowScene.windows where window.isKeyWindow {
                return window.rootViewController
            }
        }

        return nil
    }
}
