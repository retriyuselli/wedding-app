import SwiftUI

struct MoreSubpageHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text(subtitle)
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MoreSubpageNavigationHeader: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.iconOnChip)
                        .frame(width: 42, height: 42)
                        .background {
                            Circle()
                                .fill(AppTheme.iconChipFill)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .overlay {
                            Circle()
                                .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                        }
                        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(AppTheme.sageDark)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.inkMuted(0.5))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Color.clear.frame(width: 42, height: 42)
            }
        }
    }
}

struct MoreFormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            VStack(spacing: 10) {
                content()
            }
            .padding(14)
            .premiumGlassCard(cornerRadius: 20)
        }
    }
}

struct MoreInputRow: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(alignment: axis == .vertical ? .top : .center, spacing: 12) {
            MoreFieldIcon(name: icon)

            TextField(placeholder, text: $text, axis: axis)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.titleOnGlass)
                .lineLimit(axis == .vertical ? 3...5 : 1...1)
                .keyboardType(keyboard)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(MoreFieldBackground())
    }
}

struct MoreFieldIcon: View {
    let name: String

    var body: some View {
        Image(systemName: name)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(AppTheme.iconOnChip)
            .frame(width: 36, height: 36)
            .background {
                Circle()
                    .fill(AppTheme.iconChipFill)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .overlay {
                Circle()
                    .stroke(AppTheme.iconChipStroke, lineWidth: 1)
            }
    }
}

struct MoreFieldBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(AppTheme.nestedGlassFill)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.iconChipStroke, lineWidth: 1)
            }
    }
}

struct MoreEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(AppTheme.iconOnChip)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle()
                        .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                }

            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.titleOnGlass)

            Text(message)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.captionOnGlass)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .premiumGlassCard(cornerRadius: 28)
    }
}

struct MorePrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        isEnabled
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [AppTheme.sage, AppTheme.sageDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(AppTheme.sageDark.opacity(0.45))
                    )
            }
            .shadow(color: AppTheme.sageDark.opacity(isEnabled ? 0.18 : 0), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }
}
