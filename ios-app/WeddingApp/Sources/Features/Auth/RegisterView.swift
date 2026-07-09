import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @FocusState private var focusedField: AuthFormField?

    private var isEmailFormatInvalid: Bool {
        guard !email.isEmpty, email.contains("@") else { return false }
        let parts = email.split(separator: "@")
        guard parts.count == 2, let domain = parts.last else { return true }
        return !domain.contains(".")
    }

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty && !isEmailFormatInvalid
    }

    private var passwordsMismatch: Bool {
        !passwordConfirmation.isEmpty && password != passwordConfirmation
    }

    var body: some View {
        AuthScreenLayout(showsBackButton: true, onBack: { dismiss() }) {
            VStack(spacing: 0) {
                AuthHeroHeader()

                VStack(spacing: 20) {
                    AuthLabeledTextField(
                        label: L10n.Auth.fullName,
                        icon: "person",
                        placeholder: L10n.Auth.fullNamePlaceholder,
                        text: $name,
                        textContentType: .name,
                        submitLabel: .next,
                        fieldFocus: .name,
                        focusedField: $focusedField,
                        onSubmit: { focusedField = .email }
                    )

                    AuthLabeledTextField(
                        label: L10n.Auth.email,
                        icon: "envelope",
                        placeholder: L10n.Auth.emailPlaceholder,
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        submitLabel: .next,
                        fieldFocus: .email,
                        focusedField: $focusedField,
                        onSubmit: { focusedField = .password }
                    )

                    if isEmailFormatInvalid {
                        AuthHintBanner(message: L10n.Auth.invalidEmail)
                    }

                    AuthLabeledSecureField(
                        label: L10n.Auth.password,
                        placeholder: L10n.Auth.passwordPlaceholder,
                        text: $password,
                        submitLabel: .next,
                        fieldFocus: .password,
                        focusedField: $focusedField,
                        onSubmit: { focusedField = .passwordConfirmation }
                    )

                    AuthLabeledSecureField(
                        label: L10n.Auth.confirmPassword,
                        placeholder: L10n.Auth.confirmPassword,
                        text: $passwordConfirmation,
                        submitLabel: .go,
                        fieldFocus: .passwordConfirmation,
                        focusedField: $focusedField,
                        onSubmit: submitRegister
                    )

                    if passwordsMismatch {
                        AuthHintBanner(message: L10n.Auth.passwordMismatch)
                    }

                    if let errorMessage = session.errorMessage {
                        AuthErrorBanner(message: errorMessage)
                    }

                    AuthPrimaryButton(
                        title: L10n.Auth.register,
                        isLoading: session.isLoading,
                        isDisabled: !isFormValid || passwordsMismatch
                    ) {
                        submitRegister()
                    }

                    AuthSocialDivider(text: L10n.Auth.orRegisterWith)

                    VStack(spacing: 12) {
                        AuthSocialFullButton(provider: .apple) {
                            Task { await session.loginWithApple() }
                        }
                        AuthSocialFullButton(provider: .google) {
                            Task { await session.loginWithGoogle() }
                        }
                    }
                }

                AuthFooterLink(
                    prompt: L10n.Auth.haveAccount,
                    actionTitle: L10n.Auth.login
                ) {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            session.errorMessage = nil
        }
        .onChange(of: name) { _, _ in
            session.errorMessage = nil
        }
        .onChange(of: email) { _, _ in
            session.errorMessage = nil
        }
        .onChange(of: password) { _, _ in
            session.errorMessage = nil
        }
        .onChange(of: passwordConfirmation) { _, _ in
            session.errorMessage = nil
        }
    }

    private func submitRegister() {
        guard isFormValid, !passwordsMismatch, !session.isLoading else {
            return
        }

        focusedField = nil
        Task {
            await session.register(
                name: name,
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation
            )
            if session.currentUser != nil {
                dismiss()
            }
        }
    }
}
