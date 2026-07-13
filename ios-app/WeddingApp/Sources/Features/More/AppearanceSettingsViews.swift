import SwiftUI

struct ThemeSettingsView: View {
    @ObservedObject private var appearance = AppearanceStore.shared

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Settings.theme,
                        subtitle: L10n.Settings.themeChooserSub
                    )

                    section(title: L10n.Settings.colorPaletteSection) {
                        VStack(spacing: 10) {
                            ForEach(AppColorPalette.allCases) { palette in
                                colorPaletteRow(palette)
                            }
                        }
                    }

                    section(title: L10n.Settings.appearanceModeSection) {
                        VStack(spacing: 10) {
                            ForEach(AppAppearanceMode.allCases) { preference in
                                appearanceModeRow(preference)
                            }
                        }
                    }

                    infoCard(L10n.Settings.themeInfo)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func colorPaletteRow(_ palette: AppColorPalette) -> some View {
        let isSelected = appearance.colorPalette == palette

        return Button {
            appearance.selectColorPalette(palette)
        } label: {
            HStack(spacing: 14) {
                paletteSwatch(palette.previewColors)

                VStack(alignment: .leading, spacing: 3) {
                    Text(palette.title)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.ink)
                    Text(palette.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.2))
            }
            .padding(14)
            .background(
                (isSelected ? AppTheme.lightSage.opacity(0.5) : AppTheme.surface),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(isSelected ? 0.28 : 0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func appearanceModeRow(_ preference: AppAppearanceMode) -> some View {
        let isSelected = appearance.theme == preference

        return Button {
            appearance.selectTheme(preference)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: preference.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(preference.title)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.ink)
                    Text(preference.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.2))
            }
            .padding(14)
            .background(
                (isSelected ? AppTheme.lightSage.opacity(0.5) : AppTheme.surface),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(isSelected ? 0.22 : 0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func paletteSwatch(_ colors: [Color]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                color
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.ink.opacity(0.08), lineWidth: 1)
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
                .padding(.leading, 4)

            content()
        }
    }

    private func infoCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark.opacity(0.8))
                .padding(.top, 1)

            Text(text)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
        }
    }
}

struct TextSizeSettingsView: View {
    @ObservedObject private var appearance = AppearanceStore.shared

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Settings.textSize,
                        subtitle: L10n.Settings.textSizeChooserSub
                    )

                    previewCard

                    VStack(spacing: 10) {
                        ForEach(AppTextSizePreference.allCases) { preference in
                            textSizeRow(preference)
                        }
                    }

                    infoCard(L10n.Settings.textSizeInfo)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Settings.textSizePreview)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.5))

            Text(L10n.Settings.textSizePreviewSample)
                .font(.custom("Poppins-Medium", size: appearance.textSize.previewSize))
                .foregroundStyle(AppTheme.sageDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func textSizeRow(_ preference: AppTextSizePreference) -> some View {
        let isSelected = appearance.textSize == preference

        return Button {
            appearance.selectTextSize(preference)
        } label: {
            HStack(spacing: 14) {
                Text("Aa")
                    .font(.custom("Poppins-SemiBold", size: preference == .small ? 13 : preference == .medium ? 16 : 19))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(preference.title)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.ink)
                    Text(preference.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.2))
            }
            .padding(14)
            .background(
                (isSelected ? AppTheme.lightSage.opacity(0.5) : AppTheme.surface),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(isSelected ? 0.22 : 0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func infoCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark.opacity(0.8))
                .padding(.top, 1)

            Text(text)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
        }
    }
}
