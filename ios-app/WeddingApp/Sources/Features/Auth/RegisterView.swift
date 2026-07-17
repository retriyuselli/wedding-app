import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var showTerms = false
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                LoginReferenceBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: -58) {
                        LoginHeroSection(topInset: geometry.safeAreaInsets.top)
                            .frame(height: AuthLoginLayout.heroHeight(for: geometry.size.height))
                            .overlay(alignment: .topLeading) {
                                AuthLoginBackButton(action: { dismiss() })
                                    .padding(.leading, 20)
                                    .padding(.top, geometry.safeAreaInsets.top + 12)
                            }

                        RegisterFormSheet(
                            name: $name,
                            email: $email,
                            password: $password,
                            passwordConfirmation: $passwordConfirmation,
                            focusedField: $focusedField,
                            isLoading: session.isLoading,
                            isEmailFormatInvalid: isEmailFormatInvalid,
                            passwordsMismatch: passwordsMismatch,
                            errorMessage: session.errorMessage,
                            onRegister: submitRegister,
                            onApple: submitAppleLogin,
                            onGoogle: submitGoogleLogin,
                            onLogin: { dismiss() },
                            onTerms: { showTerms = true }
                        )
                        .frame(minHeight: AuthLoginLayout.formSheetMinimumHeight(for: geometry, extraPadding: 300))
                    }
                    .padding(.bottom, max(28, geometry.safeAreaInsets.bottom + 36))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height + 72, alignment: .top)
                }
                .scrollDismissesKeyboard(.interactively)

                Text(L10n.Auth.copyright)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.inkMuted(0.45))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 28)
                    .padding(.bottom, max(10, geometry.safeAreaInsets.bottom + 6))
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .background(LoginPalette.background)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.sageDark)
        .sheet(isPresented: $showTerms) {
            NavigationStack {
                TermsOfServiceView()
            }
        }
        .onAppear {
            session.resetTransientUIState()
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
        .onChange(of: session.authRevision) { _, _ in
            if session.currentUser != nil {
                dismiss()
            }
        }
    }

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

    private func submitRegister() {
        guard isFormValid, !passwordsMismatch, !session.isLoading else {
            return
        }

        focusedField = nil
        session.register(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation
        )
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

private struct RegisterFormSheet: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var passwordConfirmation: String
    var focusedField: FocusState<AuthFormField?>.Binding
    let isLoading: Bool
    let isEmailFormatInvalid: Bool
    let passwordsMismatch: Bool
    let errorMessage: String?
    let onRegister: () -> Void
    let onApple: () -> Void
    let onGoogle: () -> Void
    let onLogin: () -> Void
    let onTerms: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            LoginSheetGlassBackground()

            VStack(spacing: 0) {
                VStack(spacing: 9) {
                    LoginInputField(
                        icon: "person",
                        placeholder: L10n.Auth.fullNamePlaceholder,
                        text: $name,
                        textContentType: .name,
                        submitLabel: .next,
                        fieldFocus: .name,
                        focusedField: focusedField,
                        onSubmit: { focusedField.wrappedValue = .email }
                    )

                    LoginInputField(
                        icon: "envelope",
                        placeholder: L10n.Auth.emailPlaceholder,
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        submitLabel: .next,
                        fieldFocus: .email,
                        focusedField: focusedField,
                        onSubmit: { focusedField.wrappedValue = .password }
                    )

                    LoginPasswordField(
                        placeholder: L10n.Auth.passwordPlaceholder,
                        text: $password,
                        textContentType: .newPassword,
                        submitLabel: .next,
                        fieldFocus: .password,
                        focusedField: focusedField,
                        onSubmit: { focusedField.wrappedValue = .passwordConfirmation }
                    )

                    LoginPasswordField(
                        placeholder: L10n.Auth.confirmPassword,
                        text: $passwordConfirmation,
                        textContentType: .newPassword,
                        submitLabel: .go,
                        fieldFocus: .passwordConfirmation,
                        focusedField: focusedField,
                        onSubmit: onRegister
                    )
                }

                if isEmailFormatInvalid {
                    AuthNativeStatusMessage(message: L10n.Auth.invalidEmail, systemImage: "info.circle")
                        .padding(.top, 10)
                }

                if passwordsMismatch {
                    AuthNativeStatusMessage(message: L10n.Auth.passwordMismatch, systemImage: "info.circle")
                        .padding(.top, 10)
                }

                if let errorMessage {
                    AuthNativeStatusMessage(
                        message: errorMessage,
                        systemImage: "exclamationmark.circle.fill",
                        tint: .red
                    )
                    .padding(.top, 13)
                }

                LoginPrimaryButton(
                    title: L10n.Auth.register,
                    isLoading: isLoading,
                    isDisabled: !isFormValid || passwordsMismatch,
                    action: onRegister
                )
                .padding(.top, 14)

                LoginDivider(text: L10n.Auth.orRegisterWith)
                    .padding(.top, 16)
                    .padding(.bottom, 10)

                HStack(spacing: 12) {
                    LoginSocialButton(provider: .apple, isDisabled: isLoading, action: onApple)
                    LoginSocialButton(provider: .google, isDisabled: isLoading, action: onGoogle)
                }

                Button(action: onLogin) {
                    HStack(spacing: 8) {
                        Text(L10n.Auth.haveAccount)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(LoginPalette.textSecondary)

                        Text(L10n.Auth.login)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.sageMuted(0.95))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.sageMuted(0.95))
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.top, 18)

                Button(action: onTerms) {
                    (
                        Text(L10n.Auth.termsPrefix)
                            .foregroundStyle(LoginPalette.textSecondary)
                        + Text(L10n.Auth.termsLink)
                            .foregroundStyle(AppTheme.sageMuted(0.95))
                            .underline()
                            .fontWeight(.semibold)
                        + Text(L10n.Auth.termsSuffix)
                            .foregroundStyle(LoginPalette.textSecondary)
                    )
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(L10n.Auth.termsPrefix)\(L10n.Auth.termsLink)\(L10n.Auth.termsSuffix)")
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 34)
            .padding(.top, 36)
        }
        .frame(maxWidth: .infinity)
    }

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty && !isEmailFormatInvalid
    }
}
