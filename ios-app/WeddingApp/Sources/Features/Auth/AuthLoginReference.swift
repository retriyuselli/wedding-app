import SwiftUI

enum LoginPalette {
    static var background: Color { AppTheme.cream }
    static var green: Color { AppTheme.sageDark }
    static var greenDark: Color { AppTheme.sageDark }
    static var greenLight: Color { AppTheme.lightSage }
    static var gold: Color { AppTheme.gold }
    /// Primary field/copy color — solid ink so it stays readable on glass.
    static var textPrimary: Color { AppTheme.titleOnGlass }
    static var textSecondary: Color { AppTheme.inkMuted(0.78) }
    /// Placeholder on adaptive field fills (not on flat white — that washed out in dark mode).
    static var placeholder: Color { AppTheme.inkMuted(0.72) }
    static var icon: Color { AppTheme.sageMuted(0.95) }
    static var border: Color { AppTheme.sage.opacity(0.42) }
    static var divider: Color { AppTheme.sage.opacity(0.32) }
    static var sheet: Color { AppTheme.surface }
    static var fieldFill: Color { AppTheme.nestedGlassFill }
    /// Solid light chip for social buttons so labels stay readable in dark mode.
    static var socialFill: Color { AppTheme.selectedChipFill }
    static var socialLabel: Color { AppTheme.labelOnLightSurface }
    static var socialBorder: Color { AppTheme.iconChipStroke }
}

enum AuthLoginLayout {
    static func heroHeight(for screenHeight: CGFloat) -> CGFloat {
        min(max(screenHeight * 0.40, 314), 360)
    }

    static func formSheetMinimumHeight(for geometry: GeometryProxy, extraPadding: CGFloat = 168) -> CGFloat {
        geometry.size.height - heroHeight(for: geometry.size.height) + extraPadding + geometry.safeAreaInsets.bottom
    }
}

struct LoginReferenceBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.cream,
                AppTheme.surface,
                AppTheme.lightSage.opacity(0.55),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

/// Glass treatment for the curved auth form sheet (matches `premiumGlassCard` materials).
struct LoginSheetGlassBackground: View {
    var body: some View {
        ZStack {
            LoginSheetShape()
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.surface.opacity(0.96),
                            AppTheme.cream.opacity(0.92),
                            AppTheme.lightSage.opacity(0.45),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            LoginSheetShape()
                .fill(.ultraThinMaterial)
                .opacity(0.40)
        }
        .overlay {
            LoginSheetShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.72),
                            AppTheme.sage.opacity(0.14),
                            AppTheme.gold.opacity(0.10),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: AppTheme.sageDark.opacity(0.09), radius: 22, y: -8)
        .shadow(color: AppTheme.gold.opacity(0.05), radius: 8, y: -2)
    }
}

struct LoginHeroSection: View {
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
                        Color.white.opacity(0.04),
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
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct LoginHeroBrand: View {
    var body: some View {
        VStack(alignment: .center, spacing: 17) {
            LoginHeartLogo()
                .frame(width: 54, height: 54)

            Text(L10n.Auth.appName)
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)
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

            Text(L10n.Auth.heroTagline)
                .font(.system(size: 12, weight: .regular, design: .rounded))
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

struct LoginHeartLogo: View {
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

struct LeafStem: Shape {
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
            (0.80, 8, -5),
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

struct LoginSheetShape: Shape {
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

struct LoginBadge: View {
    var systemImage: String = "envelope.open"
    var overlaySystemImage: String? = "heart.fill"

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.lightSage.opacity(0.85),
                            AppTheme.sage.opacity(0.55),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 76, height: 76)
                .overlay {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.35)
                }
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.85),
                                    AppTheme.gold.opacity(0.25),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: AppTheme.sageDark.opacity(0.10), radius: 14, y: 6)

            Image(systemName: systemImage)
                .font(.system(size: 29, weight: .light))
                .foregroundStyle(AppTheme.sageDark.opacity(0.92))

            if let overlaySystemImage {
                Image(systemName: overlaySystemImage)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(AppTheme.gold)
                    .offset(y: -1)
            }
        }
        .accessibilityHidden(true)
    }
}

struct LoginInputField: View {
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
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(LoginPalette.icon)
                .frame(width: 28)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(LoginPalette.placeholder)
            )
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(LoginPalette.textPrimary)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .focused(focusedField, equals: fieldFocus)
            .onSubmit { onSubmit?() }
        }
        .frame(height: 50)
        .padding(.horizontal, 18)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(LoginPalette.fieldFill)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(LoginPalette.border, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture {
            focusedField.wrappedValue = fieldFocus
        }
    }
}

struct LoginPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var textContentType: UITextContentType? = .password
    var submitLabel: SubmitLabel = .done
    var fieldFocus: AuthFormField?
    var focusedField: FocusState<AuthFormField?>.Binding
    var onSubmit: (() -> Void)?

    @State private var isVisible = false
    private let cornerRadius: CGFloat = 16

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: "lock")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(LoginPalette.icon)
                .frame(width: 28)

            Group {
                if isVisible {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(LoginPalette.placeholder)
                    )
                } else {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(LoginPalette.placeholder)
                    )
                }
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(LoginPalette.textPrimary)
            .textContentType(textContentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .focused(focusedField, equals: fieldFocus)
            .onSubmit { onSubmit?() }

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(LoginPalette.icon)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 50)
        .padding(.horizontal, 18)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(LoginPalette.fieldFill)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(LoginPalette.border, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture {
            focusedField.wrappedValue = fieldFocus
        }
    }
}

struct LoginPrimaryButton: View {
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
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.titleOnGlass)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(.white.opacity(0.92))
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: isDisabled
                        ? [AppTheme.brandGradientEnd.opacity(0.72), AppTheme.quoteGradientMid.opacity(0.42)]
                        : [AppTheme.brandGradientEnd, AppTheme.quoteGradientMid],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: AppTheme.sageDark.opacity(isDisabled ? 0.06 : 0.18), radius: isDisabled ? 8 : 16, y: isDisabled ? 3 : 8)
            .shadow(color: AppTheme.gold.opacity(isDisabled ? 0 : 0.08), radius: 6, y: 2)
        }
        .buttonStyle(LoginPressButtonStyle())
        .disabled(isDisabled || isLoading)
    }
}

struct LoginDivider: View {
    let text: String

    var body: some View {
        HStack(spacing: 22) {
            line
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
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

struct LoginSocialButton: View {
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
    var title: String? = nil
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                providerIcon
                    .frame(width: 22, height: 22)

                Text(title ?? provider.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LoginPalette.socialLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LoginPalette.socialFill,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(LoginPalette.socialBorder, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.10), radius: 12, y: 5)
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
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(LoginPalette.socialLabel)
        case .google:
            Text("G")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.26, green: 0.52, blue: 0.96),
                            Color(red: 0.92, green: 0.21, blue: 0.17),
                            Color(red: 0.98, green: 0.74, blue: 0.02),
                            Color(red: 0.20, green: 0.66, blue: 0.33),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

struct LoginPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct AuthLoginBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 38, height: 38)
                .background {
                    ZStack {
                        Circle().fill(AppTheme.cream.opacity(0.65))
                        Circle().fill(.ultraThinMaterial).opacity(0.55)
                    }
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.70), lineWidth: 1)
                        .allowsHitTesting(false)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.Auth.back)
    }
}
