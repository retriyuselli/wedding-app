import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        Form {
            Section {
                AuthNativeBrandHeader()
            }
            .listRowBackground(Color.clear)

            Section {
                TextField(L10n.Auth.fullName, text: $name, prompt: Text(L10n.Auth.fullNamePlaceholder))
                    .textContentType(.name)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit { focusedField = .email }

                TextField(L10n.Auth.email, text: $email, prompt: Text(L10n.Auth.emailPlaceholder))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }

                if isEmailFormatInvalid {
                    AuthNativeStatusMessage(message: L10n.Auth.invalidEmail, systemImage: "info.circle")
                }

                SecureField(L10n.Auth.password, text: $password, prompt: Text(L10n.Auth.passwordPlaceholder))
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .password)
                    .onSubmit { focusedField = .passwordConfirmation }

                SecureField(L10n.Auth.confirmPassword, text: $passwordConfirmation, prompt: Text(L10n.Auth.confirmPassword))
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .focused($focusedField, equals: .passwordConfirmation)
                    .onSubmit(submitRegister)

                if passwordsMismatch {
                    AuthNativeStatusMessage(message: L10n.Auth.passwordMismatch, systemImage: "info.circle")
                }
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
                    title: L10n.Auth.register,
                    systemImage: "person.badge.plus.fill",
                    isLoading: session.isLoading,
                    isDisabled: !isFormValid || passwordsMismatch,
                    action: submitRegister
                )
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))

            Section(L10n.Auth.orRegisterWith) {
                AuthNativeProviderButton(provider: .apple, isDisabled: session.isLoading) {
                    submitAppleLogin()
                }

                AuthNativeProviderButton(provider: .google, isDisabled: session.isLoading) {
                    submitGoogleLogin()
                }
            }

            Section {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text(L10n.Auth.haveAccount)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(L10n.Auth.login)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle(L10n.Auth.register)
        .navigationBarTitleDisplayMode(.large)
        .tint(AppTheme.sageDark)
        .scrollDismissesKeyboard(.interactively)
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
