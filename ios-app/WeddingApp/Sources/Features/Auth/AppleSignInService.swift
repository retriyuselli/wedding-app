import AuthenticationServices
import UIKit

enum AppleSignInError: LocalizedError {
    case missingIdentityToken
    case cancelled
    case failed

    var errorDescription: String? {
        switch self {
        case .missingIdentityToken:
            return "Token Apple tidak tersedia. Coba lagi."
        case .cancelled:
            return "Login Apple dibatalkan."
        case .failed:
            return "Tidak dapat menyelesaikan login dengan Apple."
        }
    }
}

struct AppleSignInCredential {
    let identityToken: String
    let fullName: String?
    let email: String?
}

@MainActor
final class AppleSignInService: NSObject {
    static let shared = AppleSignInService()

    private var continuation: CheckedContinuation<AppleSignInCredential, Error>?

    private override init() {
        super.init()
    }

    func signIn() async throws -> AppleSignInCredential {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    private func resume(with result: Result<AppleSignInCredential, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let identityToken = String(data: tokenData, encoding: .utf8) else {
            resume(with: .failure(AppleSignInError.missingIdentityToken))
            return
        }

        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        resume(with: .success(AppleSignInCredential(
            identityToken: identityToken,
            fullName: fullName.isEmpty ? nil : fullName,
            email: credential.email
        )))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            resume(with: .failure(AppleSignInError.cancelled))
            return
        }

        resume(with: .failure(AppleSignInError.failed))
    }
}

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else {
                continue
            }

            if let keyWindow = windowScene.windows.first(where: \.isKeyWindow) {
                return keyWindow
            }
        }

        return ASPresentationAnchor()
    }
}
