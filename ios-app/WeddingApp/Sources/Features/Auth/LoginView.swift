import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showForgotPasswordComingSoon = false
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        NavigationStack {
            AuthScreenLayout {
                VStack(spacing: 0) {
                    AuthHeroHeader()

                    VStack(spacing: 20) {
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

                            AuthDottedLink(title: L10n.Auth.forgotPassword) {
                                showForgotPasswordComingSoon = true
                            }
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

                        #if DEBUG
                        Button {
                            session.simulateLoginForDebug()
                        } label: {
                            Text("Simulasi Masuk Debug")
                                .font(AppFont.medium(13))
                                .foregroundStyle(AppTheme.sageDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppTheme.lightSage.opacity(0.7), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(session.isLoading)
                        .opacity(session.isLoading ? 0.55 : 1)
                        #endif

                        AuthSocialDivider(text: L10n.Auth.orLoginWith)

                        VStack(spacing: 12) {
                            AuthSocialFullButton(provider: .apple, isDisabled: session.isLoading) {
                                submitAppleLogin()
                            }

                            AuthSocialFullButton(provider: .google, isDisabled: session.isLoading) {
                                submitGoogleLogin()
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
            .alert(L10n.Common.comingSoon, isPresented: $showForgotPasswordComingSoon) {
                Button(L10n.Common.ok, role: .cancel) {}
            } message: {
                Text(L10n.Common.comingSoonMessage)
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

    private func submitAppleLogin() {
        guard !session.isLoading else {
            return
        }

        focusedField = nil
        Task { await session.loginWithApple() }
    }

    private func submitGoogleLogin() {
        guard !session.isLoading else {
            return
        }

        focusedField = nil
        Task { await session.loginWithGoogle() }
    }
}
