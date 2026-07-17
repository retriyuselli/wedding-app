import Foundation

@MainActor
final class DataVisibilityViewModel: ObservableObject {
    @Published var settings: PrivacyVisibilitySettings?
    @Published var partnerEmailDraft = ""
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let repository: any PrivacyRepositoryProtocol

    init(repository: any PrivacyRepositoryProtocol = PrivacyRepository()) {
        self.repository = repository
    }

    var isPartnerLinked: Bool {
        settings?.partnerUserId != nil
    }

    var linkedPartnerEmail: String? {
        guard let email = settings?.partnerEmail?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            return nil
        }
        return email
    }

    var linkedPartnerName: String? {
        guard let name = settings?.partnerName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return nil
        }
        return name
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            settings = try await repository.visibilitySettings()
            partnerEmailDraft = ""
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func save() async {
        guard let settings else { return }
        isSaving = true
        errorMessage = nil
        successMessage = nil
        defer { isSaving = false }

        let trimmedEmail = partnerEmailDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let partnerEmailPayload: String? = trimmedEmail.isEmpty ? nil : trimmedEmail

        do {
            let result = try await repository.saveVisibility(settings, partnerEmail: partnerEmailPayload)
            self.settings = result.0
            partnerEmailDraft = ""

            if partnerEmailPayload != nil, self.settings?.partnerUserId != nil {
                successMessage = L10n.Privacy.partnerLinkedSuccess
            } else {
                successMessage = result.1 ?? L10n.Privacy.visibilitySaved
            }
            await PremiumStore.shared.refreshServerEntitlement()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func unlinkPartner() async {
        guard let settings else { return }
        isSaving = true
        errorMessage = nil
        successMessage = nil
        defer { isSaving = false }

        do {
            let result = try await repository.saveVisibility(settings, partnerEmail: "")
            self.settings = result.0
            partnerEmailDraft = ""
            successMessage = result.1 ?? L10n.Privacy.partnerUnlinked
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func retry() async {
        await load()
    }
}
