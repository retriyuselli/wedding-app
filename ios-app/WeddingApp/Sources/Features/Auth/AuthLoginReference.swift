import SwiftUI

enum LoginPalette {
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
                Color(red: 0.93, green: 0.90, blue: 0.83),
                Color(red: 1.00, green: 0.995, blue: 0.98),
                Color(red: 0.97, green: 0.98, blue: 0.93),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
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

struct LoginHeroBrand: View {
    var body: some View {
        VStack(alignment: .center, spacing: 17) {
            LoginHeartLogo()
                .frame(width: 54, height: 54)

            Text(L10n.Auth.appName)
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

            Text(L10n.Auth.heroTagline)
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
                .fill(LoginPalette.greenLight.opacity(0.78))
                .frame(width: 76, height: 76)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.95), lineWidth: 7)
                }

            Image(systemName: systemImage)
                .font(.system(size: 29, weight: .light))
                .foregroundStyle(.white.opacity(0.96))

            if let overlaySystemImage {
                Image(systemName: overlaySystemImage)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(.white.opacity(0.96))
                    .offset(y: -1)
            }
        }
        .accessibilityHidden(true)
    }
}

struct AuthLoginSheetFlorals: View {
    var body: some View {
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

struct LoginPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var textContentType: UITextContentType? = .password
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

struct LoginDivider: View {
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
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(LoginPalette.green)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.88), in: Circle())
                .overlay {
                    Circle()
                        .stroke(LoginPalette.border.opacity(0.55), lineWidth: 1)
                        .allowsHitTesting(false)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.Auth.back)
    }
}
