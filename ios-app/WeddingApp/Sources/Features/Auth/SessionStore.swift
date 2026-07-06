import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let deviceName = "iOS Simulator"

    func restoreSession() async {
        guard KeychainStore.loadToken() != nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let response: UserResponse = try await APIClient.shared.request("auth/me")
            currentUser = response.user
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
        }
    }

    func logout() async {
        try? await APIClient.shared.requestNoContent("auth/logout", method: "POST")
        KeychainStore.deleteToken()
        currentUser = nil
    }

    private func perform(_ action: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
