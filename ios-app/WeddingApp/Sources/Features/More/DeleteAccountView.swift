import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore

    @State private var password = ""
    @State private var confirmation = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showFinalConfirmation = false

    private var usesSocialLogin: Bool {
        session.currentUser?.hasSocialLogin ?? false
    }

    private var canDelete: Bool {
        let confirmationValid = confirmation.uppercased() == "HAPUS"
        let passwordValid = usesSocialLogin || !password.isEmpty
        return confirmationValid && passwordValid && !isLoading
    }

    private var deletedDataItems: [String] {
        [
            L10n.DeleteAccount.dataProfile,
            L10n.DeleteAccount.dataWedding,
            L10n.DeleteAccount.dataGuests,
            L10n.DeleteAccount.dataBudget,
            L10n.DeleteAccount.dataChecklist,
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.DeleteAccount.title,
                        subtitle: L10n.DeleteAccount.subtitle
                    )

                    warningCard

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    MoreFormSection(title: L10n.DeleteAccount.confirmSection) {
                        VStack(spacing: 10) {
                            if !usesSocialLogin {
                                securePasswordField
                            } else {
                                socialLoginNote
                            }

                            confirmationField
                        }
                    }

                    consequencesCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }

            deleteButton
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .alert(L10n.DeleteAccount.alertTitle, isPresented: $showFinalConfirmation) {
            Button(L10n.Privacy.deleteAccount, role: .destructive) {
                Task { await deleteAccount() }
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10n.DeleteAccount.alertMessage)
        }
    }

    private var warningCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.red.opacity(0.8))

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.DeleteAccount.warningTitle)
                    .font(AppFont.medium(14))
                    .foregroundStyle(Color.red.opacity(0.85))
                Text(L10n.DeleteAccount.warningMessage)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        }
    }

    private var securePasswordField: some View {
        HStack(spacing: 12) {
            MoreFieldIcon(name: "lock.fill")

            SecureField(L10n.DeleteAccount.passwordPlaceholder, text: $password)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .textContentType(.password)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(MoreFieldBackground())
    }

    private var socialLoginNote: some View {
        HStack(alignment: .top, spacing: 12) {
            MoreFieldIcon(name: "person.badge.key.fill")

            Text(L10n.DeleteAccount.socialNote)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(MoreFieldBackground())
    }

    private var confirmationField: some View {
        HStack(spacing: 12) {
            MoreFieldIcon(name: "textformat")

            TextField(L10n.DeleteAccount.confirmPlaceholder, text: $confirmation)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(MoreFieldBackground())
    }

    private var consequencesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.DeleteAccount.dataTitle)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink)

            ForEach(deletedDataItems, id: \.self) { item in
                HStack(spacing: 8) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.red.opacity(0.6))
                    Text(item)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                }
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var deleteButton: some View {
        Button {
            showFinalConfirmation = true
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(L10n.DeleteAccount.button)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canDelete ? Color.red.opacity(0.85) : Color.red.opacity(0.35), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canDelete)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var payload: [String: Any] = [
            "confirmation": confirmation.uppercased(),
        ]

        if !usesSocialLogin {
            payload["password"] = password
        }

        do {
            let _: MessageResponse = try await APIClient.shared.request(
                "auth/account",
                method: "DELETE",
                json: payload
            )
            session.clearSessionAfterAccountDeletion()
            dismiss()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
