import SwiftUI

struct CoupleView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var brideName = ""
    @State private var groomName = ""
    @State private var budaya = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var couplePreview: String {
        let bride = brideName.trimmingCharacters(in: .whitespacesAndNewlines)
        let groom = groomName.trimmingCharacters(in: .whitespacesAndNewlines)

        if bride.isEmpty && groom.isEmpty {
            return L10n.Couple.nameEmpty
        }
        if bride.isEmpty { return groom }
        if groom.isEmpty { return bride }
        return "\(bride) & \(groom)"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Couple.title,
                        subtitle: L10n.Couple.subtitle
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    couplePreviewCard

                    MoreFormSection(title: L10n.Couple.brideSection) {
                        MoreInputRow(icon: "person.fill", placeholder: L10n.Couple.bridePlaceholder, text: $brideName)
                    }

                    MoreFormSection(title: L10n.Couple.groomSection) {
                        MoreInputRow(icon: "person.fill", placeholder: L10n.Couple.groomPlaceholder, text: $groomName)
                    }

                    MoreFormSection(title: L10n.Couple.cultureSection) {
                        MoreInputRow(
                            icon: "heart.text.square",
                            placeholder: L10n.Couple.culturePlaceholder,
                            text: $budaya
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            MorePrimaryButton(
                title: L10n.Couple.save,
                isLoading: isLoading,
                isEnabled: canSave,
                action: { Task { await save() } }
            )
        }
        .task { await load() }
    }

    private var couplePreviewCard: some View {
        HStack(spacing: 14) {
            Image("CouplePortrait")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(couplePreview)
                    .font(AppFont.medium(18))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(2)

                Text(budaya.isEmpty ? L10n.Couple.cultureEmpty : budaya)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 20)
    }

    private var canSave: Bool {
        !brideName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !groomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request("wedding-info")
            brideName = envelope.data.brideName ?? ""
            groomName = envelope.data.groomName ?? ""
            budaya = envelope.data.budaya ?? ""
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var payload: [String: Any] = [:]

        let trimmedBride = brideName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGroom = groomName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBudaya = budaya.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedBride.isEmpty { payload["bride_name"] = trimmedBride }
        if !trimmedGroom.isEmpty { payload["groom_name"] = trimmedGroom }
        if !trimmedBudaya.isEmpty { payload["budaya"] = trimmedBudaya }

        do {
            let _: Envelope<WeddingInfo> = try await APIClient.shared.request(
                "wedding-info",
                method: "PUT",
                json: payload
            )
            dismiss()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
