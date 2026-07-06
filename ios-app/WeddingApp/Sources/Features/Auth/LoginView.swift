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
                            label: "Email atau Nomor Telepon",
                            icon: "envelope",
                            placeholder: "Masukkan email atau nomor telepon",
                            text: $email,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress,
                            submitLabel: .next,
                            fieldFocus: .email,
                            focusedField: $focusedField,
                            onSubmit: { focusedField = .password }
                        )

                        VStack(alignment: .trailing, spacing: 8) {
                            AuthLabeledSecureField(
                                label: "Kata Sandi",
                                placeholder: "Masukkan kata sandi",
                                text: $password,
                                submitLabel: .go,
                                fieldFocus: .password,
                                focusedField: $focusedField,
                                onSubmit: submitLogin
                            )

                            AuthDottedLink(title: "Lupa kata sandi?") {
                                // Forgot password — coming soon
                            }
                        }

                        if let errorMessage = session.errorMessage {
                            AuthErrorBanner(message: errorMessage)
                        }

                        AuthPrimaryButton(
                            title: "Masuk",
                            isLoading: session.isLoading,
                            isDisabled: email.isEmpty || password.isEmpty
                        ) {
                            submitLogin()
                        }

                        AuthSocialDivider(text: "atau masuk dengan")

                        VStack(spacing: 12) {
                            AuthSocialFullButton(provider: .apple) {
                                // Sign in with Apple — coming soon
                            }

                            AuthSocialFullButton(provider: .google) {
                                // Sign in with Google — coming soon
                            }

                            AuthSocialFullButton(provider: .phone) {
                                // Sign in with phone — coming soon
                            }
                        }
                    }

                    AuthFooterLink(
                        prompt: "Belum punya akun?",
                        actionTitle: "Daftar sekarang"
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

    private func submitLogin() {
        guard !email.isEmpty, !password.isEmpty, !session.isLoading else {
            return
        }

        focusedField = nil
        Task { await session.login(email: email, password: password) }
    }
}
