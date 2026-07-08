import Foundation
import UIKit

@MainActor
final class SessionStore: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var deviceName: String {
        UIDevice.current.name
    }

    func restoreSession() async {
        guard KeychainStore.loadToken() != nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let response: UserResponse = try await APIClient.shared.request("auth/me")
            currentUser = response.user
            await syncPushTokenAfterAuth()
        } catch {
            KeychainStore.deleteToken()
            currentUser = nil
        }
    }

    func login(email: String, password: String) async {
        await perform {
            let response: AuthResponse = try await APIClient.shared.request(
                "auth/login",
                method: "POST",
                json: ["email": email, "password": password, "device_name": self.deviceName]
            )
            KeychainStore.saveToken(response.token)
            self.currentUser = response.user
            await self.syncPushTokenAfterAuth()
        }
    }

    func loginWithGoogle() async {
        await perform {
            let idToken = try await GoogleSignInService.shared.signIn()
            let response: AuthResponse = try await APIClient.shared.request(
                "auth/google",
                method: "POST",
                json: ["id_token": idToken, "device_name": self.deviceName]
            )
            KeychainStore.saveToken(response.token)
            self.currentUser = response.user
            await self.syncPushTokenAfterAuth()
        }
    }

    func loginWithApple() async {
        await perform {
            let credential = try await AppleSignInService.shared.signIn()

            var json: [String: Any] = [
                "identity_token": credential.identityToken,
                "device_name": self.deviceName,
            ]
            if let fullName = credential.fullName {
                json["full_name"] = fullName
            }
            if let email = credential.email {
                json["email"] = email
            }

            let response: AuthResponse = try await APIClient.shared.request(
                "auth/apple",
                method: "POST",
                json: json
            )
            KeychainStore.saveToken(response.token)
            self.currentUser = response.user
            await self.syncPushTokenAfterAuth()
        }
    }

    func register(name: String, email: String, password: String, passwordConfirmation: String) async {
        await perform {
            let response: AuthResponse = try await APIClient.shared.request(
                "auth/register",
                method: "POST",
                json: [
                    "name": name,
                    "email": email,
                    "password": password,
                    "password_confirmation": passwordConfirmation,
                    "device_name": self.deviceName,
                ]
            )
            KeychainStore.saveToken(response.token)
            self.currentUser = response.user
            await self.syncPushTokenAfterAuth()
        }
    }

    func logout() async {
        await PushNotificationManager.shared.unregisterCurrentDeviceToken()
        try? await APIClient.shared.requestNoContent("auth/logout", method: "POST")
        clearSession()
    }

    /// Hapus state sesi secara lokal tanpa memanggil API — digunakan saat 401 atau token kedaluwarsa.
    func clearSession() {
        KeychainStore.deleteToken()
        currentUser = nil
        BudgetCategoriesStore.shared.reset()
    }

    func clearSessionAfterAccountDeletion() {
        clearSession()
    }

    private func perform(_ action: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await action()
        } catch GoogleSignInError.cancelled {
            return
        } catch AppleSignInError.cancelled {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func syncPushTokenAfterAuth() async {
        await PushNotificationManager.shared.syncDeviceTokenIfPossible()
    }
}
