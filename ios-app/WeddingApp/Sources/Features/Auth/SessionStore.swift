import Foundation
import UIKit

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var authRevision = 0

    private var restoreGeneration = 0
    private var loginTask: Task<Void, Never>?

    private var deviceName: String {
        UIDevice.current.name
    }

    func restoreSession(timeout: Duration = .seconds(5)) async {
        guard KeychainStore.loadToken() != nil else {
            return
        }

        let generation = restoreGeneration

        await withTaskGroup(of: Bool.self) { group in
            group.addTask { @MainActor in
                await self.performSessionRestore(generation: generation)
                return true
            }

            group.addTask {
                try? await Task.sleep(for: timeout)
                return false
            }

            while let result = await group.next() {
                if result {
                    group.cancelAll()
                    return
                }

                return
            }
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
            let response = try await Self.fetchCurrentUser()
            guard generation == restoreGeneration else {
                return
            }

            currentUser = response.user
            authRevision += 1
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

    func login(email: String, password: String) {
        loginTask?.cancel()
        loginTask = Task {
            await performEmailLogin(email: email, password: password)
        }
    }

    private func performEmailLogin(email: String, password: String) async {
        invalidateRestore()
        let deviceName = deviceName
        await performAuthentication {
            try await Self.loginRequest(
                email: email,
                password: password,
                deviceName: deviceName
            )
        }
    }

    func loginWithGoogle() async {
        invalidateRestore()
        isLoading = true
        errorMessage = nil

        do {
            let idToken = try await GoogleSignInService.shared.signIn()
            let response = try await Self.socialLoginRequest(
                path: "auth/google",
                json: ["id_token": idToken, "device_name": deviceName]
            )
            completeAuthentication(with: response)
        } catch GoogleSignInError.cancelled {
            isLoading = false
        } catch {
            isLoading = false
            await handleAuthenticationFailure(error)
        }
    }

    func loginWithApple() async {
        invalidateRestore()
        isLoading = true
        errorMessage = nil

        do {
            let credential = try await AppleSignInService.shared.signIn()

            var json: [String: Any] = [
                "identity_token": credential.identityToken,
                "device_name": deviceName,
            ]
            if let fullName = credential.fullName {
                json["full_name"] = fullName
            }
            if let email = credential.email {
                json["email"] = email
            }

            let response = try await Self.socialLoginRequest(path: "auth/apple", json: json)
            completeAuthentication(with: response)
        } catch AppleSignInError.cancelled {
            isLoading = false
        } catch {
            isLoading = false
            await handleAuthenticationFailure(error)
        }
    }

    func register(name: String, email: String, password: String, passwordConfirmation: String) {
        loginTask?.cancel()
        loginTask = Task {
            invalidateRestore()
            let deviceName = deviceName
            await performAuthentication {
                try await Self.registerRequest(
                    name: name,
                    email: email,
                    password: password,
                    passwordConfirmation: passwordConfirmation,
                    deviceName: deviceName
                )
            }
        }
    }

    func logout() async {
        invalidateRestore()
        loginTask?.cancel()
        loginTask = nil
        await PushNotificationManager.shared.unregisterCurrentDeviceToken()
        try? await APIClient.shared.requestNoContent("auth/logout", method: "POST")
        clearSession()
    }

    func clearSession() {
        invalidateRestore()
        loginTask?.cancel()
        loginTask = nil
        KeychainStore.deleteToken()
        currentUser = nil
        isLoading = false
        authRevision += 1
        BudgetCategoriesStore.shared.reset()
    }

    func clearSessionAfterAccountDeletion() {
        clearSession()
    }

    func resetTransientUIState() {
        isLoading = false
        errorMessage = nil
    }

    func updateCurrentUser(_ user: User) {
        currentUser = user
        authRevision += 1
    }

    private func invalidateRestore() {
        restoreGeneration += 1
    }

    private func performAuthentication(
        _ request: @Sendable () async throws -> AuthResponse
    ) async {
        guard !Task.isCancelled else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await request()
            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            completeAuthentication(with: response)
        } catch is CancellationError {
            isLoading = false
        } catch GoogleSignInError.cancelled {
            isLoading = false
        } catch AppleSignInError.cancelled {
            isLoading = false
        } catch {
            isLoading = false
            await handleAuthenticationFailure(error)
        }
    }

    private func handleAuthenticationFailure(_ error: Error) async {
        if error is URLError {
            await APIResolver.invalidateAndResolve()
        }

        let message = error.userFacingMessage
        if !message.isEmpty {
            errorMessage = message
        }

        #if DEBUG
        print("[Auth] Authentication failed: \(error)")
        #endif
    }

    private func completeAuthentication(with response: AuthResponse) {
        KeychainStore.saveToken(response.token)
        currentUser = response.user
        isLoading = false
        authRevision += 1
        objectWillChange.send()
        schedulePushTokenSync()

        #if DEBUG
        print("[Auth] Login succeeded for user id \(response.user.id), authRevision=\(authRevision)")
        #endif
    }

    private func schedulePushTokenSync() {
        Task(priority: .utility) {
            await PushNotificationManager.shared.prepareAfterAuthentication()
        }
    }

    private nonisolated static func fetchCurrentUser() async throws -> UserResponse {
        try await APIClient.shared.request("auth/me")
    }

    private nonisolated static func loginRequest(
        email: String,
        password: String,
        deviceName: String
    ) async throws -> AuthResponse {
        try await APIClient.shared.request(
            "auth/login",
            method: "POST",
            json: ["email": email, "password": password, "device_name": deviceName]
        )
    }

    private nonisolated static func registerRequest(
        name: String,
        email: String,
        password: String,
        passwordConfirmation: String,
        deviceName: String
    ) async throws -> AuthResponse {
        try await APIClient.shared.request(
            "auth/register",
            method: "POST",
            json: [
                "name": name,
                "email": email,
                "password": password,
                "password_confirmation": passwordConfirmation,
                "device_name": deviceName,
            ]
        )
    }

    private nonisolated static func socialLoginRequest(
        path: String,
        json: [String: Any]
    ) async throws -> AuthResponse {
        try await APIClient.shared.request(path, method: "POST", json: json)
    }
}
