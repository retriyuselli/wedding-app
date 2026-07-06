import SwiftUI

// MARK: - Focus

enum AuthFormField: Hashable {
    case name
    case email
    case password
    case passwordConfirmation
}

// MARK: - Background

struct AuthBackgroundView: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.96)
                .ignoresSafeArea()

            VStack {
                Spacer()

                AuthBottomWaveDecoration()
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()

                    Image("FloralHeader")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 260)
                        .offset(x: 52, y: -36)
                        .allowsHitTesting(false)
                }

                Spacer()
            }
            .ignoresSafeArea()

            VStack {
                Spacer()

                HStack {
                    Image("AuthFloralCorner")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .scaleEffect(x: 1, y: -1)
                        .opacity(0.55)
                        .offset(x: -18, y: 88)
                        .allowsHitTesting(false)

                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct AuthBottomWaveDecoration: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            WaveShape(amplitude: 18, phase: 0)
                .fill(AppTheme.lightSage.opacity(0.55))
                .frame(height: 90)

            WaveShape(amplitude: 14, phase: .pi / 2)
                .fill(AppTheme.sage.opacity(0.12))
                .frame(height: 70)
                .offset(y: 8)
        }
    }
}

private struct WaveShape: Shape {
    var amplitude: CGFloat
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.minY + amplitude

        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: midY))

        let waveLength = rect.width / 2
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relative = x / waveLength
            let y = midY + sin(relative * .pi * 2 + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Layout

struct AuthScreenLayout<Content: View>: View {
    var showsBackButton: Bool = false
    var onBack: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            AuthBackgroundView()

            ScrollView(showsIndicators: false) {
                content()
                    .padding(.horizontal, 24)
                    .padding(.top, showsBackButton ? 52 : 28)
                    .padding(.bottom, 36)
            }
            .scrollDismissesKeyboard(.interactively)

            if showsBackButton, let onBack {
                AuthBackButton(action: onBack)
                    .padding(.leading, 16)
                    .padding(.top, 8)
            }
        }
    }
}

struct AuthBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.sageDark.opacity(0.7))
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Header

struct AuthHeroHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Wedding App")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text("Teman terbaik dalam merencanakan hari bahagia Anda.")
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.gold)

                Text("Every love story is beautiful")
                    .font(.custom("Snell Roundhand", size: 17))
                    .foregroundStyle(AppTheme.gold)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 28)
    }
}

// MARK: - Fields

struct AuthLabeledTextField: View {
    let label: String
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
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFont.semibold(14))
                .foregroundStyle(AppTheme.sageDark)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                    .frame(width: 20)

                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .font(AppFont.regular(14))
                        .foregroundStyle(AppTheme.ink.opacity(0.28))
                )
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .focused(focusedField, equals: fieldFocus)
                .onSubmit {
                    onSubmit?()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.14), lineWidth: 1)
            }
        }
    }
}

struct AuthLabeledSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var submitLabel: SubmitLabel = .done
    var fieldFocus: AuthFormField?
    var focusedField: FocusState<AuthFormField?>.Binding
    var onSubmit: (() -> Void)?

    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFont.semibold(14))
                .foregroundStyle(AppTheme.sageDark)

            HStack(spacing: 10) {
                Image(systemName: "lock")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                    .frame(width: 20)

                Group {
                    if isVisible {
                        TextField(
                            "",
                            text: $text,
                            prompt: Text(placeholder)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink.opacity(0.28))
                        )
                    } else {
                        SecureField(
                            "",
                            text: $text,
                            prompt: Text(placeholder)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink.opacity(0.28))
                        )
                    }
                }
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .focused(focusedField, equals: fieldFocus)
                .onSubmit {
                    onSubmit?()
                }

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(AppTheme.sageDark.opacity(0.55))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.14), lineWidth: 1)
            }
        }
    }
}

// MARK: - Feedback

struct AuthErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.red.opacity(0.8))

            Text(message)
                .font(AppFont.regular(12))
                .foregroundStyle(Color.red.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color.red.opacity(0.05), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct AuthHintBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.sageDark.opacity(0.7))

            Text(message)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(AppTheme.lightSage.opacity(0.4), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Buttons & Links

struct AuthPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(AppFont.semibold(15))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isDisabled ? AppTheme.sage.opacity(0.4) : AppTheme.sageDark,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
        .buttonStyle(AuthPressableButtonStyle())
        .disabled(isDisabled || isLoading)
    }
}

private struct AuthPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct AuthDottedLink: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.sageDark)
                .underline()
        }
        .buttonStyle(.plain)
    }
}

struct AuthSocialDivider: View {
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            line
            Text(text)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.38))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            line
        }
        .padding(.vertical, 4)
    }

    private var line: some View {
        Rectangle()
            .fill(AppTheme.sage.opacity(0.12))
            .frame(height: 1)
    }
}

struct AuthSocialFullButton: View {
    enum Provider {
        case apple
        case google
        case phone

        var icon: String {
            switch self {
            case .apple: return "apple.logo"
            case .google: return "g.circle.fill"
            case .phone: return "phone"
            }
        }

        var label: String {
            switch self {
            case .apple: return "Lanjutkan dengan Apple"
            case .google: return "Lanjutkan dengan Google"
            case .phone: return "Lanjutkan dengan Nomor Telepon"
            }
        }

        var iconColor: Color {
            switch self {
            case .apple: return AppTheme.ink
            case .google: return Color(red: 0.26, green: 0.52, blue: 0.96)
            case .phone: return AppTheme.sageDark
            }
        }
    }

    let provider: Provider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: provider.icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(provider.iconColor)
                    .frame(width: 22)

                Text(provider.label)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink.opacity(0.75))

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.14), lineWidth: 1)
            }
        }
        .buttonStyle(AuthPressableButtonStyle())
    }
}

struct AuthFooterLink: View {
    let prompt: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(prompt)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                Text("\(actionTitle) >")
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.sageDark)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - Legacy helpers

struct AuthLogoView: View {
    var showsTagline: Bool = true
    var compact: Bool = false

    var body: some View {
        AuthHeroHeader()
    }
}

struct AuthFormCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
    }
}

struct AuthSocialButton: View {
    let provider: AuthSocialFullButton.Provider
    let action: () -> Void

    var body: some View {
        AuthSocialFullButton(provider: provider, action: action)
    }
}

struct AuthSocialIconRow: View {
    let onApple: () -> Void
    let onGoogle: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            AuthSocialFullButton(provider: .apple, action: onApple)
            AuthSocialFullButton(provider: .google, action: onGoogle)
            AuthSocialFullButton(provider: .phone, action: {})
        }
    }
}

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        AuthLabeledTextField(
            label: placeholder,
            icon: icon,
            placeholder: placeholder,
            text: $text,
            keyboardType: keyboardType,
            textContentType: textContentType,
            focusedField: $focusedField
        )
    }
}

struct AuthSecureField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var focusedField: AuthFormField?

    var body: some View {
        AuthLabeledSecureField(
            label: placeholder,
            placeholder: placeholder,
            text: $text,
            focusedField: $focusedField
        )
    }
}

struct AuthDivider: View {
    var body: some View {
        AuthSocialDivider(text: "atau")
    }
}

struct AuthAppleButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        AuthSocialFullButton(provider: .apple, action: action)
    }
}
