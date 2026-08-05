import Foundation

@MainActor
final class HelpCenterViewModel: ObservableObject {
    @Published private(set) var payload: HelpCenterPayload?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var searchText = ""

    private let repository: any PrivacyRepositoryProtocol

    init(repository: any PrivacyRepositoryProtocol = PrivacyRepository()) {
        self.repository = repository
    }

    var filteredFAQs: [HelpCenterFAQ] {
        guard let payload else { return [] }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return payload.faqs }
        return payload.faqs.filter {
            $0.question.lowercased().contains(query) || $0.answer.lowercased().contains(query)
        }
    }

    func load(locale: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            payload = try await repository.helpCenter(locale: locale)
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func retry(locale: String) async {
        await load(locale: locale)
    }
}
