import Foundation

@MainActor
final class TwoFactorViewModel: ObservableObject {
    @Published private(set) var status: TwoFactorStatus?
    @Published var code = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isBusy = false
    @Published var awaitingCode = false
    @Published var disableMode = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let repository: any PrivacyRepositoryProtocol

    init(repository: any PrivacyRepositoryProtocol = PrivacyRepository()) {
        self.repository = repository
    }

    var isEnabled: Bool { status?.enabled ?? false }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            status = try await repository.twoFactorStatus()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func startEnable() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            successMessage = try await repository.startEnableTwoFactor()
            disableMode = false
            awaitingCode = true
            code = ""
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func confirmEnable() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await repository.finishEnableTwoFactor(code: code)
            status = result.0
            successMessage = result.1
            awaitingCode = false
            code = ""
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func startDisable() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            successMessage = try await repository.startDisableTwoFactor()
            disableMode = true
            awaitingCode = true
            code = ""
            password = ""
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func confirmDisable() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await repository.finishDisableTwoFactor(code: code, password: password)
            status = result.0
            successMessage = result.1
            awaitingCode = false
            code = ""
            password = ""
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func retry() async {
        await load()
    }
}
