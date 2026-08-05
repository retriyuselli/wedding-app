import Foundation

@MainActor
final class PrivacySecurityViewModel: ObservableObject {
    @Published private(set) var summary: PrivacySecuritySummary?
    @Published private(set) var twoFactorEnabled = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let repository: any PrivacyRepositoryProtocol

    init(repository: any PrivacyRepositoryProtocol = PrivacyRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let summaryTask = repository.securitySummary()
            async let twoFactorTask = repository.twoFactorStatus()
            summary = try await summaryTask
            twoFactorEnabled = try await twoFactorTask.enabled
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func retry() async {
        await load()
    }
}
