import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var newPasswordConfirmation = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    @FocusState private var focusedField: Field?

    private enum Field {
        case current
        case new
        case confirm
    }

    private var passwordsMismatch: Bool {
        !newPasswordConfirmation.isEmpty && newPassword != newPasswordConfirmation
    }

    private var canSave: Bool {
        !currentPassword.isEmpty
            && newPassword.count >= 8
            && newPassword == newPasswordConfirmation
            && !isLoading
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.ChangePassword.title,
                        subtitle: L10n.ChangePassword.subtitle
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    MoreFormSection(title: L10n.ChangePassword.section) {
                        secureField(
                            icon: "lock.fill",
                            placeholder: L10n.ChangePassword.current,
                            text: $currentPassword,
                            field: .current
                        )

                        secureField(
                            icon: "key.fill",
                            placeholder: L10n.ChangePassword.newPassword,
                            text: $newPassword,
                            field: .new
                        )

                        secureField(
                            icon: "key.fill",
                            placeholder: L10n.ChangePassword.confirm,
                            text: $newPasswordConfirmation,
                            field: .confirm
                        )

                        if passwordsMismatch {
                            Text(L10n.ChangePassword.mismatch)
                                .font(AppFont.regular(12))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    infoCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }

            saveButton
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .alert(L10n.Common.success, isPresented: $showSuccess) {
            Button(L10n.Common.ok) { dismiss() }
        } message: {
            Text(L10n.ChangePassword.successMessage)
        }
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark.opacity(0.75))

            Text(L10n.ChangePassword.info)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(L10n.ChangePassword.save)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSave ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private func secureField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        HStack(spacing: 12) {
            MoreFieldIcon(name: icon)

            SecureField(placeholder, text: text)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .focused($focusedField, equals: field)
                .textContentType(field == .current ? .password : .newPassword)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(MoreFieldBackground())
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let _: MessageResponse = try await APIClient.shared.request(
                "auth/password",
                method: "PUT",
                json: [
                    "current_password": currentPassword,
                    "password": newPassword,
                    "password_confirmation": newPasswordConfirmation,
                ]
            )
            showSuccess = true
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
