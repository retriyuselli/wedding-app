import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        NavigationStack {
            AuthScreenLayout {
                VStack(spacing: 0) {
                    AuthHeroHeader()

                    VStack(spacing: 20) {
                        AuthLabeledTextField(
                            label: L10n.Auth.emailOrPhone,
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

                        VStack(alignment: .trailing, spacing: 8) {
                            AuthLabeledSecureField(
                                label: L10n.Auth.password,
                                placeholder: L10n.Auth.passwordPlaceholder,
                                text: $password,
                                submitLabel: .go,
                                fieldFocus: .password,
                                focusedField: $focusedField,
                                onSubmit: submitLogin
                            )

                        }

                        if let errorMessage = session.errorMessage {
                            AuthErrorBanner(message: errorMessage)
                        }

                        AuthPrimaryButton(
                            title: L10n.Auth.login,
                            isLoading: session.isLoading,
                            isDisabled: email.isEmpty || password.isEmpty || isEmailFormatInvalid
                        ) {
                            submitLogin()
                        }

                        AuthSocialDivider(text: L10n.Auth.orLoginWith)

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
                        prompt: L10n.Auth.noAccount,
                        actionTitle: L10n.Auth.registerNow
                    ) {
                        showRegister = true
                    }
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .onChange(of: email) { _, _ in
                session.errorMessage = nil
            }
            .onChange(of: password) { _, _ in
                session.errorMessage = nil
            }
        }
    }

    private var isEmailFormatInvalid: Bool {
        guard !email.isEmpty, email.contains("@") else { return false }
        let parts = email.split(separator: "@")
        guard parts.count == 2, let domain = parts.last else { return true }
        return !domain.contains(".")
    }

    private func submitLogin() {
        guard !email.isEmpty, !password.isEmpty, !isEmailFormatInvalid, !session.isLoading else {
            return
        }

        focusedField = nil
        Task { await session.login(email: email, password: password) }
    }
}
