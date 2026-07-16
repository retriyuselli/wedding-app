import Foundation

@MainActor
final class SharedUserDetailViewModel: ObservableObject {
    @Published var profile: SharedDirectoryUser?
    @Published var viewerRole: String?
    @Published var wedding: SharedWeddingPayload?
    @Published var guests: [Guest] = []
    @Published var budget: SharedBudgetPayload?

    @Published var isLoadingProfile = false
    @Published var isLoadingExtras = false
    @Published var profileError: String?
    @Published var weddingError: String?
    @Published var guestsError: String?
    @Published var budgetError: String?

    let userId: Int

    private let repository: any SharedPrivacyRepositoryProtocol

    init(userId: Int, repository: any SharedPrivacyRepositoryProtocol = SharedPrivacyRepository()) {
        self.userId = userId
        self.repository = repository
    }

    func load() async {
        isLoadingProfile = true
        profileError = nil
        defer { isLoadingProfile = false }

        do {
            let result = try await repository.profile(userId: userId)
            profile = result.0
            viewerRole = result.1
            await loadAccessibleSections()
        } catch {
            guard !error.isRequestCancelled else { return }
            profileError = error.userFacingMessage
        }
    }

    private func loadAccessibleSections() async {
        isLoadingExtras = true
        weddingError = nil
        guestsError = nil
        budgetError = nil
        defer { isLoadingExtras = false }

        async let weddingResult = loadWedding()
        async let guestsResult = loadGuests()
        async let budgetResult = loadBudget()
        _ = await (weddingResult, guestsResult, budgetResult)
    }

    private func loadWedding() async {
        do {
            let result = try await repository.wedding(userId: userId)
            wedding = result.0
            if viewerRole == nil {
                viewerRole = result.1
            }
        } catch {
            guard !error.isRequestCancelled else { return }
            wedding = nil
            weddingError = error.userFacingMessage
        }
    }

    private func loadGuests() async {
        do {
            let result = try await repository.guests(userId: userId)
            guests = result.0
            if viewerRole == nil {
                viewerRole = result.1
            }
        } catch {
            guard !error.isRequestCancelled else { return }
            guests = []
            guestsError = error.userFacingMessage
        }
    }

    private func loadBudget() async {
        do {
            let result = try await repository.budget(userId: userId)
            budget = result.0
            if viewerRole == nil {
                viewerRole = result.1
            }
        } catch {
            guard !error.isRequestCancelled else { return }
            budget = nil
            budgetError = error.userFacingMessage
        }
    }
}
