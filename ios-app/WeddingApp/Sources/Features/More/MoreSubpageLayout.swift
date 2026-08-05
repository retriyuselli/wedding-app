import SwiftUI

struct MoreSubpageHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.serifBold(32))
                .foregroundStyle(AppTheme.titleOnBackground)

            Text(subtitle)
                .font(AppFont.serifRegular(12))
                .foregroundStyle(AppTheme.mutedOnBackground)
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
                        .foregroundStyle(AppTheme.iconOnChrome)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.chrome, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(AppTheme.hairline, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(spacing: 4) {
                    Text(title)
                        .font(AppFont.serifSemibold(18))
                        .foregroundStyle(AppTheme.titleOnBackground)
                    Text(subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.mutedOnBackground)
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
                .font(AppFont.serifSemibold(14))
                .foregroundStyle(AppTheme.titleOnBackground)

            VStack(spacing: 10) {
                content()
            }
            .padding(14)
            .premiumListRow(cornerRadius: 20)
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
                .font(AppFont.regular(14))
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
            .background(AppTheme.iconChipFill, in: Circle())
    }
}

struct MoreFieldBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(AppTheme.surface)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.hairline.opacity(0.7), lineWidth: 1)
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
                .background(AppTheme.iconChipFill, in: Circle())

            Text(title)
                .font(AppFont.semibold(16))
                .foregroundStyle(AppTheme.titleOnGlass)

            Text(message)
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.captionOnGlass)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .premiumListRow(cornerRadius: 28)
    }
}

/// Empty-state copy that stays on Poppins + SF Serif. Prefer over `ContentUnavailableView` (SF Pro).
struct AppEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var onBackground: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppTheme.iconOnChip)
                .frame(width: 72, height: 72)
                .background(AppTheme.iconChipFill, in: Circle())

            Text(title)
                .font(AppFont.semibold(17))
                .foregroundStyle(onBackground ? AppTheme.titleOnBackground : AppTheme.titleOnGlass)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppFont.regular(13))
                .foregroundStyle(onBackground ? AppTheme.mutedOnBackground : AppTheme.captionOnLightSurface)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
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
                        .tint(AppTheme.primaryActionForeground(enabled: isEnabled))
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(AppFont.semibold(16))
            }
            .foregroundStyle(AppTheme.primaryActionForeground(enabled: isEnabled))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.primaryActionFill(enabled: isEnabled))
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(AppTheme.surface)
    }
}
