import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showForgotPassword = false
    @State private var showTerms = false
    @State private var twoFactorCode = ""
    @State private var appeared = false
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        brandHeader
                            .padding(.top, 28)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)

                        loginCard
                            .padding(.top, 36)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 18)

                        termsFooter
                            .padding(.top, 28)
                            .padding(.bottom, 24)
                            .opacity(appeared ? 1 : 0)
                    }
                    .padding(.horizontal, 28)
                    .frame(maxWidth: 440)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            }
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
            .sheet(isPresented: $showTerms) {
                NavigationStack {
                    TermsOfServiceView()
                }
            }
            .sheet(isPresented: Binding(
                get: { session.pendingTwoFactorToken != nil },
                set: { if !$0 { session.cancelTwoFactorChallenge(); twoFactorCode = "" } }
            )) {
                twoFactorSheet
            }
            .onAppear {
                session.resetTransientUIState()
                withAnimation(.easeOut(duration: 0.55)) {
                    appeared = true
                }
            }
            .onChange(of: email) { _, _ in session.errorMessage = nil }
            .onChange(of: password) { _, _ in session.errorMessage = nil }
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            WeddingRingAnimation(
                ringsApart: false,
                glowActive: true,
                shimmer: true
            )
            .frame(width: 120, height: 96)
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                HStack(spacing: 7) {
                    Text(L10n.Auth.brandWedding)
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(L10n.Auth.brandApp)
                        .foregroundStyle(AppTheme.gold)
                }
                .font(.system(size: 34, weight: .bold, design: .serif))
                .shadow(color: AppTheme.sageDark.opacity(0.10), radius: 8, y: 2)

                Text(L10n.Dashboard.planTogether)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundStyle(AppTheme.inkMuted(0.75))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var loginCard: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                LoginInputField(
                    icon: "envelope",
                    placeholder: L10n.Auth.emailPlaceholder,
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .username,
                    submitLabel: .next,
                    fieldFocus: .email,
                    focusedField: $focusedField,
                    onSubmit: { focusedField = .password }
                )

                LoginPasswordField(
                    placeholder: L10n.Auth.passwordPlaceholder,
                    text: $password,
                    submitLabel: .go,
                    fieldFocus: .password,
                    focusedField: $focusedField,
                    onSubmit: submitLogin
                )
            }

            HStack {
                if isEmailFormatInvalid {
                    AuthNativeStatusMessage(message: L10n.Auth.invalidEmail, systemImage: "info.circle")
                }

                Spacer(minLength: 0)

                Button {
                    showForgotPassword = true
                } label: {
                    Text(L10n.Auth.forgotPassword)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.sageMuted(0.95))
                }
                .buttonStyle(.plain)
            }

            if let errorMessage = session.errorMessage {
                AuthNativeStatusMessage(
                    message: errorMessage,
                    systemImage: "exclamationmark.circle.fill",
                    tint: .red
                )
            }

            LoginPrimaryButton(
                title: L10n.Auth.login,
                isLoading: session.isLoading,
                isDisabled: email.isEmpty || password.isEmpty || isEmailFormatInvalid,
                action: submitLogin
            )

            LoginDivider(text: L10n.Auth.or)

            VStack(spacing: 10) {
                LoginSocialButton(
                    provider: .apple,
                    title: L10n.Auth.continueApple,
                    isDisabled: session.isLoading,
                    action: submitAppleLogin
                )
                LoginSocialButton(
                    provider: .google,
                    title: L10n.Auth.continueGoogle,
                    isDisabled: session.isLoading,
                    action: submitGoogleLogin
                )
            }

            Button {
                showRegister = true
            } label: {
                HStack(spacing: 6) {
                    Text(L10n.Auth.noAccount)
                        .foregroundStyle(LoginPalette.textSecondary)
                    Text(L10n.Auth.registerNow)
                        .foregroundStyle(AppTheme.sageMuted(0.95))
                        .fontWeight(.semibold)
                }
                .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(22)
        .premiumGlassCard(cornerRadius: 28)
    }

    private var termsFooter: some View {
        Button {
            showTerms = true
        } label: {
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
    }

    private var twoFactorSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.Auth.twoFactorTitle)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.titleOnGlass)
                Text(session.pendingTwoFactorMessage ?? L10n.Auth.twoFactorMessage)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.inkMuted(0.65))

                TextField(
                    "",
                    text: $twoFactorCode,
                    prompt: Text(L10n.Auth.twoFactorCodePlaceholder)
                        .foregroundStyle(AppTheme.inkMuted(0.72))
                )
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.titleOnGlass)
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.nestedGlassFill)
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
                                colors: [AppTheme.quoteGradientLeading, AppTheme.quoteGradientMid],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
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

    private var isEmailFormatInvalid: Bool {
        guard !email.isEmpty, email.contains("@") else { return false }
        let parts = email.split(separator: "@")
        guard parts.count == 2, let domain = parts.last else { return true }
        return !domain.contains(".")
    }

    private func submitLogin() {
        guard !email.isEmpty, !password.isEmpty, !isEmailFormatInvalid, !session.isLoading else { return }
        focusedField = nil
        session.login(email: email, password: password)
    }

    private func submitAppleLogin() {
        guard !session.isLoading else { return }
        focusedField = nil
        Task { await session.loginWithApple() }
    }

    private func submitGoogleLogin() {
        guard !session.isLoading else { return }
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
                    .foregroundStyle(didSendRequest ? AppTheme.sageMuted(0.95) : AppTheme.gold)
                    .frame(width: 58, height: 58)
                    .background {
                        Circle()
                            .fill(AppTheme.iconChipFill)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                Text(L10n.Auth.forgotTitle)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.titleOnGlass)
                    .multilineTextAlignment(.center)

                Text(L10n.Auth.forgotSubtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.inkMuted(0.65))
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
        .background(LuxuryWeddingBackground())
        .onAppear { focusedField = .email }
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
        guard !isSubmitting else { return }

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
