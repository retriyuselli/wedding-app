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
            .tint(LoginPalette.green)
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
                        Text("Verifikasi dua langkah")
                            .font(AppFont.medium(18))
                        Text(session.pendingTwoFactorMessage ?? "Masukkan kode 6 digit yang dikirim ke email Anda.")
                            .font(AppFont.regular(13))
                            .foregroundStyle(.secondary)

                        TextField("Kode 6 digit", text: $twoFactorCode)
                            .keyboardType(.numberPad)
                            .font(AppFont.regular(16))
                            .padding(14)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                        if let errorMessage = session.errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                        }

                        Button {
                            Task { await session.verifyTwoFactor(code: twoFactorCode) }
                        } label: {
                            Text(session.isLoading ? "Memverifikasi…" : "Verifikasi")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(twoFactorCode.count != 6 || session.isLoading)

                        Spacer()
                    }
                    .padding(20)
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
                .fill(LoginPalette.greenLight.opacity(0.55))
                .frame(width: 46, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 18)

            VStack(spacing: 13) {
                Image(systemName: didSendRequest ? "checkmark.seal.fill" : "key.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(didSendRequest ? LoginPalette.green : LoginPalette.gold)
                    .frame(width: 58, height: 58)
                    .background(LoginPalette.greenLight.opacity(0.26), in: Circle())

                Text(L10n.Auth.forgotTitle)
                    .font(AppFont.semibold(22))
                    .foregroundStyle(LoginPalette.green)
                    .multilineTextAlignment(.center)

                Text(L10n.Auth.forgotSubtitle)
                    .font(AppFont.regular(13))
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
                        tint: didSendRequest ? LoginPalette.green : .red
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
                    .font(AppFont.medium(14))
                    .foregroundStyle(LoginPalette.green)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(LoginPalette.sheet.ignoresSafeArea())
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
            LoginSheetShape()
                .fill(LoginPalette.sheet)
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: -8)

            VStack(spacing: 0) {
                LoginBadge()
                    .offset(y: -5)
                    .padding(.bottom, 0)

                HStack(spacing: 8) {
                    Text(L10n.Auth.welcome)
                        .font(AppFont.semibold(27))
                        .foregroundStyle(LoginPalette.green)

                    Image(systemName: "heart")
                        .font(.system(size: 19, weight: .light))
                        .foregroundStyle(LoginPalette.gold)
                        .offset(y: 2)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.78)

                Text(L10n.Auth.loginSubtitle)
                    .font(AppFont.regular(12))
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
                        .font(AppFont.medium(15))
                        .foregroundStyle(LoginPalette.green)
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
                            .font(AppFont.regular(13))
                            .foregroundStyle(LoginPalette.textSecondary)

                        Text(L10n.Auth.registerNow)
                            .font(AppFont.semibold(13))
                            .foregroundStyle(LoginPalette.green)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(LoginPalette.green)
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
