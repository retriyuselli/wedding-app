import Foundation

@MainActor
final class DataExportViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var exportFileURL: URL?

    private let repository: any PrivacyRepositoryProtocol

    init(repository: any PrivacyRepositoryProtocol = PrivacyRepository()) {
        self.repository = repository
    }

    func export() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            exportFileURL = try await repository.exportAccountData()
            successMessage = "Ekspor data siap dibuka atau dibagikan."
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func retry() async {
        await export()
    }
}
