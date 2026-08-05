import Foundation

@MainActor
final class SharedDirectoryViewModel: ObservableObject {
    @Published var users: [SharedDirectoryUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: any SharedPrivacyRepositoryProtocol

    init(repository: any SharedPrivacyRepositoryProtocol = SharedPrivacyRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            users = try await repository.directory()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }
}
