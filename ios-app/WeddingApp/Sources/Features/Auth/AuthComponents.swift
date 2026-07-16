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
            LinearGradient(
                colors: [
                    AppTheme.cream,
                    AppTheme.surface,
                    AppTheme.lightSage.opacity(0.45),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                AuthBottomWaveDecoration()
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
                .foregroundStyle(AppTheme.sageDark.opacity(0.78))
                .frame(width: 36, height: 36)
                .background {
                    ZStack {
                        Circle().fill(AppTheme.cream.opacity(0.65))
                        Circle().fill(.ultraThinMaterial).opacity(0.50)
                    }
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.70), lineWidth: 1)
                        .allowsHitTesting(false)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.07), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Header

struct AuthHeroHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Auth.appName)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text(L10n.Auth.tagline)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.gold)

                Text(L10n.Auth.taglineQuote)
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

    private let cornerRadius: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.titleOnGlass)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppTheme.sageMuted(0.85))
                    .frame(width: 20)

                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.inkMuted(0.72))
                )
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.titleOnGlass)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .focused(focusedField, equals: fieldFocus)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onSubmit {
                    onSubmit?()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.nestedGlassFill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.72),
                                AppTheme.sage.opacity(0.18),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onTapGesture {
                if let fieldFocus {
                    focusedField.wrappedValue = fieldFocus
                }
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
    private let cornerRadius: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.titleOnGlass)

            HStack(spacing: 10) {
                Image(systemName: "lock")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppTheme.sageMuted(0.85))
                    .frame(width: 20)

                Group {
                    if isVisible {
                        TextField(
                            "",
                            text: $text,
                            prompt: Text(placeholder)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(AppTheme.inkMuted(0.72))
                        )
                    } else {
                        SecureField(
                            "",
                            text: $text,
                            prompt: Text(placeholder)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(AppTheme.inkMuted(0.72))
                        )
                    }
                }
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.titleOnGlass)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .focused(focusedField, equals: fieldFocus)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onSubmit {
                    onSubmit?()
                }

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(AppTheme.sageMuted(0.75))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.nestedGlassFill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.72),
                                AppTheme.sage.opacity(0.18),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onTapGesture {
                if let fieldFocus {
                    focusedField.wrappedValue = fieldFocus
                }
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
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: isDisabled
                        ? [AppTheme.sage.opacity(0.55), AppTheme.sageDark.opacity(0.48)]
                        : [AppTheme.sage, AppTheme.sageDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: AppTheme.sageDark.opacity(isDisabled ? 0.06 : 0.18), radius: isDisabled ? 8 : 16, y: isDisabled ? 3 : 8)
            .shadow(color: AppTheme.gold.opacity(isDisabled ? 0 : 0.08), radius: 6, y: 2)
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
            case .apple: return L10n.Auth.continueApple
            case .google: return L10n.Auth.continueGoogle
            case .phone: return L10n.Auth.continuePhone
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
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: provider.icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(provider.iconColor)
                    .frame(width: 22)

                Text(provider.label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ink.opacity(0.75))

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background {
                ZStack {
                    Capsule(style: .continuous)
                        .fill(AppTheme.cream.opacity(0.50))
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.60)
                }
            }
            .overlay {
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.75),
                                AppTheme.sage.opacity(0.16),
                                AppTheme.gold.opacity(0.08),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 12, y: 5)
        }
        .buttonStyle(AuthPressableButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.55 : 1)
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

// MARK: - Native Auth Components

struct AuthNativeBrandHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(AppTheme.sageDark)
                .symbolRenderingMode(.hierarchical)
                .padding(.bottom, 4)

            Text(L10n.Auth.appName)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text(L10n.Auth.tagline)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

struct AuthNativeStatusMessage: View {
    let message: String
    var systemImage: String = "info.circle"
    var tint: Color = AppTheme.sageDark

    var body: some View {
        Label {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
        }
        .labelStyle(.titleAndIcon)
        .accessibilityElement(children: .combine)
    }
}

struct AuthNativeSubmitButton: View {
    let title: String
    let systemImage: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: systemImage)
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: isDisabled
                        ? [AppTheme.sage.opacity(0.55), AppTheme.sageDark.opacity(0.48)]
                        : [AppTheme.sage, AppTheme.sageDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: AppTheme.sageDark.opacity(isDisabled ? 0.06 : 0.16), radius: isDisabled ? 8 : 14, y: isDisabled ? 3 : 6)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
    }
}

struct AuthNativeProviderButton: View {
    enum Provider {
        case apple
        case google

        var title: String {
            switch self {
            case .apple: return L10n.Auth.continueApple
            case .google: return L10n.Auth.continueGoogle
            }
        }

        var systemImage: String {
            switch self {
            case .apple: return "apple.logo"
            case .google: return "g.circle.fill"
            }
        }
    }

    let provider: Provider
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(provider.title, systemImage: provider.systemImage)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.ink.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background {
                    ZStack {
                        Capsule(style: .continuous)
                            .fill(AppTheme.cream.opacity(0.50))
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(0.60)
                    }
                }
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.75),
                                    AppTheme.sage.opacity(0.16),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .allowsHitTesting(false)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 12, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.55 : 1)
    }
}

struct AuthNativeFormCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumGlassCard(cornerRadius: 20)
    }
}

struct AuthNativeFieldLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AuthNativeFieldContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    private let cornerRadius: CGFloat = 14

    var body: some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppTheme.cream.opacity(0.55))
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.55)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.04), radius: 8, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
        AuthSocialDivider(text: L10n.Auth.or)
    }
}

struct AuthAppleButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        AuthSocialFullButton(provider: .apple, action: action)
    }
}
