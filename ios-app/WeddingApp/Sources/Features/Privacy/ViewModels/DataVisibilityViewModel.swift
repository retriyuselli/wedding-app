import Foundation

@MainActor
final class DataVisibilityViewModel: ObservableObject {
    @Published var settings: PrivacyVisibilitySettings?
    @Published var isLoading = false
    @Published var isSaving = false
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
            settings = try await repository.visibilitySettings()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func save() async {
        guard let settings else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let result = try await repository.saveVisibility(settings)
            self.settings = result.0
            successMessage = result.1 ?? "Pengaturan visibilitas berhasil disimpan."
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func retry() async {
        await load()
    }
}
