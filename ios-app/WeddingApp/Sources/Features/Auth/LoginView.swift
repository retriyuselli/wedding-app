import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showForgotPassword = false
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    LoginReferenceBackground()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: -58) {
                            LoginHeroSection(topInset: geometry.safeAreaInsets.top)
                                .frame(height: heroHeight(for: geometry.size.height))

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
                            .frame(minHeight: formSheetMinimumHeight(for: geometry))
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

    private func heroHeight(for screenHeight: CGFloat) -> CGFloat {
        min(max(screenHeight * 0.40, 314), 360)
    }

    private func formSheetMinimumHeight(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.height - heroHeight(for: geometry.size.height) + 168 + geometry.safeAreaInsets.bottom
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

                Text("Atur ulang kata sandi")
                    .font(AppFont.semibold(22))
                    .foregroundStyle(LoginPalette.green)
                    .multilineTextAlignment(.center)

                Text("Masukkan email akun Anda. Kami akan mengirim instruksi untuk membuat kata sandi baru.")
                    .font(AppFont.regular(13))
                    .foregroundStyle(LoginPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 10)
            }

            VStack(spacing: 12) {
                LoginInputField(
                    icon: "envelope",
                    placeholder: "Masukkan email Anda",
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
                    title: didSendRequest ? "Kirim ulang instruksi" : "Kirim instruksi reset",
                    isLoading: isSubmitting,
                    isDisabled: !canSubmit,
                    action: submitForgotPassword
                )
            }
            .padding(.top, 22)

            Button {
                dismiss()
            } label: {
                Text("Kembali ke login")
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
            statusMessage = "Email wajib diisi."
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
                    statusMessage = "Jika email terdaftar, instruksi reset kata sandi sudah dikirim."
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

private enum LoginPalette {
    static let background = Color(red: 0.96, green: 0.94, blue: 0.88)
    static let green = Color(red: 0.26, green: 0.36, blue: 0.19)
    static let greenDark = Color(red: 0.22, green: 0.32, blue: 0.16)
    static let greenLight = Color(red: 0.72, green: 0.77, blue: 0.64)
    static let gold = Color(red: 0.78, green: 0.61, blue: 0.32)
    static let textPrimary = Color(red: 0.18, green: 0.24, blue: 0.18)
    static let textSecondary = Color(red: 0.35, green: 0.36, blue: 0.41)
    static let placeholder = Color(red: 0.58, green: 0.59, blue: 0.63)
    static let border = Color(red: 0.70, green: 0.76, blue: 0.66)
    static let divider = Color(red: 0.80, green: 0.80, blue: 0.78)
    static let sheet = Color(red: 1.00, green: 0.995, blue: 0.985)
}

private struct LoginReferenceBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.93, green: 0.90, blue: 0.83),
                Color(red: 1.00, green: 0.995, blue: 0.98),
                Color(red: 0.97, green: 0.98, blue: 0.93)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct LoginHeroSection: View {
    let topInset: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("CouplePortrait")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: geometry.size.width * 0.64,
                        height: geometry.size.height + 150,
                        alignment: .bottomTrailing
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .offset(x: 58, y: 34)

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.70),
                        Color.white.opacity(0.20),
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                RadialGradient(
                    colors: [Color.white.opacity(0.92), Color.white.opacity(0.00)],
                    center: .topTrailing,
                    startRadius: 12,
                    endRadius: 260
                )
                .opacity(0.72)

                LoginHeroBrand()
                    .frame(maxWidth: geometry.size.width * 0.52, alignment: .leading)
                    .padding(.leading, 26)
                    .padding(.top, topInset + 88)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .zIndex(2)

                Image("FloralHeader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.30)
                    .scaleEffect(x: -1, y: 1)
                    .rotationEffect(.degrees(-7))
                    .opacity(0.86)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .offset(x: -42, y: 46)
                    .zIndex(1)

                Image("FloralHeader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.20)
                    .rotationEffect(.degrees(12))
                    .opacity(0.62)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .offset(x: 44, y: 64)
                    .zIndex(1)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

private struct LoginHeroBrand: View {
    var body: some View {
        VStack(alignment: .center, spacing: 17) {
            LoginHeartLogo()
                .frame(width: 54, height: 54)

            Text("Wedding App")
                .font(AppFont.semibold(25))
                .foregroundStyle(LoginPalette.green)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            HStack(spacing: 9) {
                Rectangle()
                    .fill(LoginPalette.gold.opacity(0.72))
                    .frame(width: 40, height: 1.1)

                Image(systemName: "heart.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(LoginPalette.gold.opacity(0.82))

                Rectangle()
                    .fill(LoginPalette.gold.opacity(0.72))
                    .frame(width: 40, height: 1.1)
            }

            Text("Rencanakan hari bahagiamu\ndengan mudah dan terorganisir")
                .font(AppFont.regular(11))
                .foregroundStyle(LoginPalette.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Image(systemName: "leaf")
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(LoginPalette.green.opacity(0.78))
        }
        .accessibilityElement(children: .combine)
    }
}

private struct LoginHeartLogo: View {
    var body: some View {
        ZStack {
            Image(systemName: "heart")
                .font(.system(size: 62, weight: .light))
                .foregroundStyle(LoginPalette.green)
                .symbolRenderingMode(.monochrome)

            LeafStem()
                .stroke(LoginPalette.green, style: StrokeStyle(lineWidth: 3.3, lineCap: .round, lineJoin: .round))
                .frame(width: 43, height: 43)
                .offset(x: 1, y: 10)
        }
    }
}

private struct LeafStem: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 3, y: rect.maxY - 5))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 4, y: rect.minY + 7),
            control1: CGPoint(x: rect.midX - 1, y: rect.midY + 4),
            control2: CGPoint(x: rect.midX + 14, y: rect.midY - 5)
        )

        let leaves: [(CGFloat, CGFloat, CGFloat)] = [
            (0.36, -10, 6),
            (0.52, 10, -5),
            (0.67, -9, 6),
            (0.80, 8, -5)
        ]

        for leaf in leaves {
            let x = rect.minX + rect.width * leaf.0
            let y = rect.maxY - rect.height * leaf.0
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + leaf.1, y: y + leaf.2))
        }

        return path
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
                .overlay(alignment: .bottom) {
                    bottomFlorals
                }

            VStack(spacing: 0) {
                LoginBadge()
                    .offset(y: -5)
                    .padding(.bottom, 0)

                HStack(spacing: 8) {
                    Text("Selamat datang!")
                        .font(AppFont.semibold(27))
                        .foregroundStyle(LoginPalette.green)

                    Image(systemName: "heart")
                        .font(.system(size: 19, weight: .light))
                        .foregroundStyle(LoginPalette.gold)
                        .offset(y: 2)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.78)

                Text("Masuk untuk melanjutkan persiapan pernikahanmu")
                    .font(AppFont.regular(12))
                    .foregroundStyle(LoginPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                    .padding(.bottom, 12)

                VStack(spacing: 9) {
                    LoginInputField(
                        icon: "envelope",
                        placeholder: "Masukkan email Anda",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        submitLabel: .next,
                        fieldFocus: .email,
                        focusedField: focusedField,
                        onSubmit: { focusedField.wrappedValue = .password }
                    )

                    LoginPasswordField(
                        placeholder: "Masukkan kata sandi",
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
                    Text("Lupa kata sandi?")
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
                    title: "Masuk ke akun saya",
                    isLoading: isLoading,
                    isDisabled: email.isEmpty || password.isEmpty || isEmailFormatInvalid,
                    action: onLogin
                )
                .padding(.top, 14)

                LoginDivider(text: "atau")
                    .padding(.top, 16)
                    .padding(.bottom, 10)

                HStack(spacing: 12) {
                    LoginSocialButton(provider: .apple, isDisabled: isLoading, action: onApple)
                    LoginSocialButton(provider: .google, isDisabled: isLoading, action: onGoogle)
                }

                Button(action: onRegister) {
                    HStack(spacing: 8) {
                        Text("Belum punya akun?")
                            .font(AppFont.regular(13))
                            .foregroundStyle(LoginPalette.textSecondary)

                        Text("Daftar sekarang")
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

    private var bottomFlorals: some View {
        HStack(alignment: .bottom) {
            Image("FloralHeader")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .scaleEffect(x: -1, y: -1)
                .rotationEffect(.degrees(6))
                .offset(x: -30, y: 22)

            Spacer()

            Image("FloralHeader")
                .resizable()
                .scaledToFit()
                .frame(width: 168)
                .scaleEffect(x: 1, y: -1)
                .rotationEffect(.degrees(-8))
                .offset(x: 38, y: 22)
        }
        .allowsHitTesting(false)
    }
}

private struct LoginSheetShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topY = rect.minY + 92
        path.move(to: CGPoint(x: rect.minX, y: topY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: topY + 26),
            control: CGPoint(x: rect.midX, y: rect.minY + 6)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct LoginBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LoginPalette.greenLight.opacity(0.78))
                .frame(width: 76, height: 76)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.95), lineWidth: 7)
                }

            Image(systemName: "envelope.open")
                .font(.system(size: 29, weight: .light))
                .foregroundStyle(.white.opacity(0.96))

            Image(systemName: "heart.fill")
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(.white.opacity(0.96))
                .offset(y: -1)
        }
        .accessibilityHidden(true)
    }
}

private struct LoginInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var submitLabel: SubmitLabel = .done
    var fieldFocus: AuthFormField?
    var focusedField: FocusState<AuthFormField?>.Binding
    var onSubmit: (() -> Void)?

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(LoginPalette.green)
                .frame(width: 28)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundStyle(LoginPalette.placeholder)
            )
            .font(AppFont.regular(14))
            .foregroundStyle(LoginPalette.textPrimary)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .focused(focusedField, equals: fieldFocus)
            .onSubmit { onSubmit?() }
        }
        .frame(height: 48)
        .padding(.horizontal, 18)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(LoginPalette.border.opacity(0.82), lineWidth: 1.1)
                .allowsHitTesting(false)
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            focusedField.wrappedValue = fieldFocus
        }
    }
}

private struct LoginPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var submitLabel: SubmitLabel = .done
    var fieldFocus: AuthFormField?
    var focusedField: FocusState<AuthFormField?>.Binding
    var onSubmit: (() -> Void)?

    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: "lock")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(LoginPalette.green)
                .frame(width: 28)

            Group {
                if isVisible {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .foregroundStyle(LoginPalette.placeholder)
                    )
                } else {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .foregroundStyle(LoginPalette.placeholder)
                    )
                }
            }
            .font(AppFont.regular(14))
            .foregroundStyle(LoginPalette.textPrimary)
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .focused(focusedField, equals: fieldFocus)
            .onSubmit { onSubmit?() }

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 21, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.86))
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 48)
        .padding(.horizontal, 18)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(LoginPalette.border.opacity(0.82), lineWidth: 1.1)
                .allowsHitTesting(false)
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            focusedField.wrappedValue = fieldFocus
        }
    }
}

private struct LoginPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(AppFont.semibold(15))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                LinearGradient(
                    colors: isDisabled
                        ? [LoginPalette.green.opacity(0.72), LoginPalette.greenDark.opacity(0.68)]
                        : [Color(red: 0.38, green: 0.49, blue: 0.26), Color(red: 0.24, green: 0.34, blue: 0.17)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
        .buttonStyle(LoginPressButtonStyle())
        .disabled(isDisabled || isLoading)
    }
}

private struct LoginDivider: View {
    let text: String

    var body: some View {
        HStack(spacing: 22) {
            line
            Text(text)
                .font(AppFont.regular(13))
                .foregroundStyle(LoginPalette.textSecondary)
                .lineLimit(1)
            line
        }
    }

    private var line: some View {
        Rectangle()
            .fill(LoginPalette.divider)
            .frame(height: 1)
    }
}

private struct LoginSocialButton: View {
    enum Provider {
        case apple
        case google

        var title: String {
            switch self {
            case .apple: return "Apple"
            case .google: return "Google"
            }
        }
    }

    let provider: Provider
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                providerIcon
                    .frame(width: 24, height: 24)

                Text(provider.title)
                    .font(AppFont.semibold(15))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.13), lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(LoginPressButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.55 : 1)
    }

    @ViewBuilder
    private var providerIcon: some View {
        switch provider {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.black)
        case .google:
            Text("G")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.26, green: 0.52, blue: 0.96),
                            Color(red: 0.92, green: 0.21, blue: 0.17),
                            Color(red: 0.98, green: 0.74, blue: 0.02),
                            Color(red: 0.20, green: 0.66, blue: 0.33)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

private struct LoginPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
