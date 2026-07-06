import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @FocusState private var focusedField: AuthFormField?

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty
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
                        label: "Nama Lengkap",
                        icon: "person",
                        placeholder: "Masukkan nama lengkap",
                        text: $name,
                        textContentType: .name,
                        submitLabel: .next,
                        fieldFocus: .name,
                        focusedField: $focusedField,
                        onSubmit: { focusedField = .email }
                    )

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

                    AuthLabeledSecureField(
                        label: "Kata Sandi",
                        placeholder: "Masukkan kata sandi",
                        text: $password,
                        submitLabel: .next,
                        fieldFocus: .password,
                        focusedField: $focusedField,
                        onSubmit: { focusedField = .passwordConfirmation }
                    )

                    AuthLabeledSecureField(
                        label: "Konfirmasi Kata Sandi",
                        placeholder: "Ulangi kata sandi",
                        text: $passwordConfirmation,
                        submitLabel: .go,
                        fieldFocus: .passwordConfirmation,
                        focusedField: $focusedField,
                        onSubmit: submitRegister
                    )

                    if passwordsMismatch {
                        AuthHintBanner(message: "Konfirmasi kata sandi tidak cocok.")
                    }

                    if let errorMessage = session.errorMessage {
                        AuthErrorBanner(message: errorMessage)
                    }

                    AuthPrimaryButton(
                        title: "Daftar",
                        isLoading: session.isLoading,
                        isDisabled: !isFormValid || passwordsMismatch
                    ) {
                        submitRegister()
                    }

                    AuthSocialDivider(text: "atau daftar dengan")

                    VStack(spacing: 12) {
                        AuthSocialFullButton(provider: .apple) {}
                        AuthSocialFullButton(provider: .google) {}
                        AuthSocialFullButton(provider: .phone) {}
                    }
                }

                AuthFooterLink(
                    prompt: "Sudah punya akun?",
                    actionTitle: "Masuk"
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
