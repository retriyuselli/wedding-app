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
            Form {
                Section {
                    AuthNativeBrandHeader()
                }
                .listRowBackground(Color.clear)

                Section {
                    TextField(L10n.Auth.email, text: $email, prompt: Text(L10n.Auth.emailPlaceholder))
                        .keyboardType(.emailAddress)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                        .onSubmit { focusedField = .password }

                    if isEmailFormatInvalid {
                        AuthNativeStatusMessage(message: L10n.Auth.invalidEmail, systemImage: "info.circle")
                    }

                    SecureField(L10n.Auth.password, text: $password, prompt: Text(L10n.Auth.passwordPlaceholder))
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .focused($focusedField, equals: .password)
                        .onSubmit(submitLogin)

                    Button(L10n.Auth.forgotPassword) {
                        showForgotPasswordComingSoon = true
                    }
                    .font(.callout)
                }

                if let errorMessage = session.errorMessage {
                    Section {
                        AuthNativeStatusMessage(
                            message: errorMessage,
                            systemImage: "exclamationmark.circle.fill",
                            tint: .red
                        )
                    }
                }

                Section {
                    AuthNativeSubmitButton(
                        title: L10n.Auth.login,
                        systemImage: "arrow.right.circle.fill",
                        isLoading: session.isLoading,
                        isDisabled: email.isEmpty || password.isEmpty || isEmailFormatInvalid,
                        action: submitLogin
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))

                Section(L10n.Auth.orLoginWith) {
                    AuthNativeProviderButton(provider: .apple, isDisabled: session.isLoading) {
                        submitAppleLogin()
                    }

                    AuthNativeProviderButton(provider: .google, isDisabled: session.isLoading) {
                        submitGoogleLogin()
                    }
                }

                Section {
                    Button {
                        showRegister = true
                    } label: {
                        HStack {
                            Text(L10n.Auth.noAccount)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(L10n.Auth.registerNow)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle(L10n.Auth.login)
            .navigationBarTitleDisplayMode(.large)
            .tint(AppTheme.sageDark)
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .alert(L10n.Common.comingSoon, isPresented: $showForgotPasswordComingSoon) {
                Button(L10n.Common.ok, role: .cancel) {}
            } message: {
                Text(L10n.Common.comingSoonMessage)
            }
            .onAppear {
                session.errorMessage = nil
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
