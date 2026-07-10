import Foundation
import UIKit

@MainActor
final class SessionStore: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var restoreGeneration = 0

    private var deviceName: String {
        UIDevice.current.name
    }

    func restoreSession(timeout: Duration = .seconds(5)) async {
        guard KeychainStore.loadToken() != nil else {
            return
        }

        let generation = restoreGeneration

        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                await self.performSessionRestore(generation: generation)
            }

            group.addTask {
                try? await Task.sleep(for: timeout)
            }

            _ = await group.next()
            group.cancelAll()
        }
    }

    private func performSessionRestore(generation: Int) async {
        guard generation == restoreGeneration else {
            return
        }

        guard KeychainStore.loadToken() != nil else {
            return
        }

        do {
            let response: UserResponse = try await APIClient.shared.request("auth/me")
            guard generation == restoreGeneration else {
                return
            }

            currentUser = response.user
            schedulePushTokenSync()
        } catch {
            guard generation == restoreGeneration else {
                return
            }

            if error.isRequestCancelled {
                return
            }

            KeychainStore.deleteToken()
            currentUser = nil
        }
    }

    func login(email: String, password: String) async {
        invalidateRestore()
        await perform {
            let response: AuthResponse = try await APIClient.shared.request(
                "auth/login",
                method: "POST",
                json: ["email": email, "password": password, "device_name": self.deviceName]
            )
            self.completeAuthentication(with: response)
        }
    }

    func loginWithGoogle() async {
        invalidateRestore()
        await perform {
            let idToken = try await GoogleSignInService.shared.signIn()
            let response: AuthResponse = try await APIClient.shared.request(
                "auth/google",
                method: "POST",
                json: ["id_token": idToken, "device_name": self.deviceName]
            )
            self.completeAuthentication(with: response)
        }
    }

    func loginWithApple() async {
        invalidateRestore()
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
            self.completeAuthentication(with: response)
        }
    }

    func register(name: String, email: String, password: String, passwordConfirmation: String) async {
        invalidateRestore()
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
            self.completeAuthentication(with: response)
        }
    }

    func logout() async {
        invalidateRestore()
        await PushNotificationManager.shared.unregisterCurrentDeviceToken()
        try? await APIClient.shared.requestNoContent("auth/logout", method: "POST")
        clearSession()
    }

    /// Hapus state sesi secara lokal tanpa memanggil API — digunakan saat 401 atau token kedaluwarsa.
    func clearSession() {
        invalidateRestore()
        KeychainStore.deleteToken()
        currentUser = nil
        BudgetCategoriesStore.shared.reset()
    }

    func clearSessionAfterAccountDeletion() {
        clearSession()
    }

    private func invalidateRestore() {
        restoreGeneration += 1
    }

    private func perform(_ action: @escaping () async throws -> Void) async {
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
            if error is URLError {
                await APIResolver.invalidateAndResolve()
            }

            let message = error.userFacingMessage
            if !message.isEmpty {
                errorMessage = message
            }
        }
    }

    private func completeAuthentication(with response: AuthResponse) {
        KeychainStore.saveToken(response.token)
        currentUser = response.user
        schedulePushTokenSync()

        #if DEBUG
        print("[Auth] Login succeeded for user id \(response.user.id)")
        #endif
    }

    private func schedulePushTokenSync() {
        Task(priority: .utility) {
            await PushNotificationManager.shared.prepareAfterAuthentication()
        }
    }
}
