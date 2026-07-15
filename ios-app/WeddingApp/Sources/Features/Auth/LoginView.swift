import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showForgotPassword = false
    @State private var twoFactorCode = ""
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    LoginReferenceBackground()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: -58) {
                            LoginHeroSection(topInset: geometry.safeAreaInsets.top)
                                .frame(height: AuthLoginLayout.heroHeight(for: geometry.size.height))

                            LoginFormSheet(
                                email: $email,
                                password: $password,
                                focusedField: $focusedField,
                                isLoading: session.isLoading,
                                isEmailFormatInvalid: isEmailFormatInvalid,
                                errorMessage: session.errorMessage,
                                onForgotPassword: { showForgotPassword = true },
                                onLogin: submitLogin,
                                onApple: submitAppleLogin,
                                onGoogle: submitGoogleLogin,
                                onRegister: { showRegister = true }
                            )
                            .frame(minHeight: AuthLoginLayout.formSheetMinimumHeight(for: geometry))
                            .padding(.horizontal, 0)
                        }
                        .padding(.bottom, max(18, geometry.safeAreaInsets.bottom + 8))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height + 72, alignment: .top)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .ignoresSafeArea(.container, edges: [.top, .bottom])
            }
            .background(LoginPalette.background)
            .toolbar(.hidden, for: .navigationBar)
            .tint(AppTheme.sageDark)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordSheet(initialEmail: email)
                    .presentationDetents([.height(390), .medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: Binding(
                get: { session.pendingTwoFactorToken != nil },
                set: { if !$0 { session.cancelTwoFactorChallenge(); twoFactorCode = "" } }
            )) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.Auth.twoFactorTitle)
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundStyle(AppTheme.sageDark)
                        Text(session.pendingTwoFactorMessage ?? L10n.Auth.twoFactorMessage)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.ink.opacity(0.55))

                        TextField(L10n.Auth.twoFactorCodePlaceholder, text: $twoFactorCode)
                            .keyboardType(.numberPad)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .padding(14)
                            .background {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppTheme.cream.opacity(0.55))
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.55)
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
                            }

                        if let errorMessage = session.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(.red)
                        }

                        Button {
                            Task { await session.verifyTwoFactor(code: twoFactorCode) }
                        } label: {
                            Text(session.isLoading ? L10n.Auth.twoFactorVerifying : L10n.Auth.twoFactorVerify)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [AppTheme.sage, AppTheme.sageDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                )
                                .shadow(color: AppTheme.sageDark.opacity(0.16), radius: 14, y: 6)
                        }
                        .buttonStyle(.plain)
                        .disabled(twoFactorCode.count != 6 || session.isLoading)
                        .opacity(twoFactorCode.count != 6 || session.isLoading ? 0.55 : 1)

                        Spacer()
                    }
                    .padding(20)
                    .premiumGlassCard(cornerRadius: 24)
                    .padding(16)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(L10n.Common.cancel) {
                                session.cancelTwoFactorChallenge()
                                twoFactorCode = ""
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
                .presentationBackground(AppTheme.cream.opacity(0.95))
            }
            .onAppear {
                session.resetTransientUIState()
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
        session.login(email: email, password: password)
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

private struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String
    @State private var isSubmitting = false
    @State private var statusMessage: String?
    @State private var didSendRequest = false
    @FocusState private var focusedField: AuthFormField?

    init(initialEmail: String) {
        _email = State(initialValue: initialEmail)
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(AppTheme.sage.opacity(0.40))
                .frame(width: 46, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 18)

            VStack(spacing: 13) {
                Image(systemName: didSendRequest ? "checkmark.seal.fill" : "key.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(didSendRequest ? AppTheme.sageDark : AppTheme.gold)
                    .frame(width: 58, height: 58)
                    .background {
                        ZStack {
                            Circle().fill(AppTheme.lightSage.opacity(0.45))
                            Circle().fill(.ultraThinMaterial).opacity(0.40)
                        }
                    }
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 10, y: 4)

                Text(L10n.Auth.forgotTitle)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)
                    .multilineTextAlignment(.center)

                Text(L10n.Auth.forgotSubtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(LoginPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 10)
            }

            VStack(spacing: 12) {
                LoginInputField(
                    icon: "envelope",
                    placeholder: L10n.Auth.emailPlaceholder,
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    submitLabel: .send,
                    fieldFocus: .email,
                    focusedField: $focusedField,
                    onSubmit: submitForgotPassword
                )

                if let statusMessage {
                    AuthNativeStatusMessage(
                        message: statusMessage,
                        systemImage: didSendRequest ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                        tint: didSendRequest ? AppTheme.sageDark : .red
                    )
                }

                LoginPrimaryButton(
                    title: didSendRequest ? L10n.Auth.forgotResend : L10n.Auth.forgotSend,
                    isLoading: isSubmitting,
                    isDisabled: !canSubmit,
                    action: submitForgotPassword
                )
            }
            .padding(.top, 22)

            Button {
                dismiss()
            } label: {
                Text(L10n.Auth.forgotBackToLogin)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            LinearGradient(
                colors: [
                    AppTheme.surface.opacity(0.98),
                    AppTheme.cream.opacity(0.94),
                    AppTheme.lightSage.opacity(0.35),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .overlay {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.35)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            focusedField = .email
        }
        .onChange(of: email) { _, _ in
            statusMessage = nil
            didSendRequest = false
        }
    }

    private var canSubmit: Bool {
        !isSubmitting && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isEmailFormatInvalid
    }

    private var isEmailFormatInvalid: Bool {
        guard email.contains("@") else { return false }
        let parts = email.split(separator: "@")
        guard parts.count == 2, let domain = parts.last else { return true }
        return !domain.contains(".")
    }

    private func submitForgotPassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            statusMessage = L10n.Auth.emailRequired
            return
        }
        guard !isEmailFormatInvalid else {
            statusMessage = L10n.Auth.invalidEmail
            return
        }
        guard !isSubmitting else {
            return
        }

        focusedField = nil
        isSubmitting = true
        statusMessage = nil

        Task {
            do {
                try await APIClient.shared.requestNoContent(
                    "auth/forgot-password",
                    method: "POST",
                    json: ["email": trimmedEmail]
                )
                await MainActor.run {
                    didSendRequest = true
                    statusMessage = L10n.Auth.forgotSent
                    isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    didSendRequest = false
                    statusMessage = error.userFacingMessage
                    isSubmitting = false
                }
            }
        }
    }
}

private struct LoginFormSheet: View {
    @Binding var email: String
    @Binding var password: String
    var focusedField: FocusState<AuthFormField?>.Binding
    let isLoading: Bool
    let isEmailFormatInvalid: Bool
    let errorMessage: String?
    let onForgotPassword: () -> Void
    let onLogin: () -> Void
    let onApple: () -> Void
    let onGoogle: () -> Void
    let onRegister: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            LoginSheetGlassBackground()

            VStack(spacing: 0) {
                LoginBadge()
                    .offset(y: -5)
                    .padding(.bottom, 0)

                HStack(spacing: 8) {
                    Text(L10n.Auth.welcome)
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundStyle(AppTheme.sageDark)

                    Image(systemName: "heart")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(AppTheme.gold)
                        .offset(y: 2)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.78)

                Text(L10n.Auth.loginSubtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(LoginPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                    .padding(.bottom, 12)

                VStack(spacing: 9) {
                    LoginInputField(
                        icon: "envelope",
                        placeholder: L10n.Auth.emailPlaceholder,
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        submitLabel: .next,
                        fieldFocus: .email,
                        focusedField: focusedField,
                        onSubmit: { focusedField.wrappedValue = .password }
                    )

                    LoginPasswordField(
                        placeholder: L10n.Auth.passwordPlaceholder,
                        text: $password,
                        submitLabel: .go,
                        fieldFocus: .password,
                        focusedField: focusedField,
                        onSubmit: onLogin
                    )
                }

                if isEmailFormatInvalid {
                    AuthNativeStatusMessage(message: L10n.Auth.invalidEmail, systemImage: "info.circle")
                        .padding(.top, 10)
                }

                Button(action: onForgotPassword) {
                    Text(L10n.Auth.forgotPassword)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                if let errorMessage {
                    AuthNativeStatusMessage(
                        message: errorMessage,
                        systemImage: "exclamationmark.circle.fill",
                        tint: .red
                    )
                .padding(.top, 13)
                }

                LoginPrimaryButton(
                    title: L10n.Auth.loginCta,
                    isLoading: isLoading,
                    isDisabled: email.isEmpty || password.isEmpty || isEmailFormatInvalid,
                    action: onLogin
                )
                .padding(.top, 14)

                LoginDivider(text: L10n.Auth.or)
                    .padding(.top, 16)
                    .padding(.bottom, 10)

                HStack(spacing: 12) {
                    LoginSocialButton(provider: .apple, isDisabled: isLoading, action: onApple)
                    LoginSocialButton(provider: .google, isDisabled: isLoading, action: onGoogle)
                }

                Button(action: onRegister) {
                    HStack(spacing: 8) {
                        Text(L10n.Auth.noAccount)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(LoginPalette.textSecondary)

                        Text(L10n.Auth.registerNow)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.sageDark)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.sageDark)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 34)
            .padding(.top, 18)
        }
        .frame(maxWidth: .infinity)
    }
}
