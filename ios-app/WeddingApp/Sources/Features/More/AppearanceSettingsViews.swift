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
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(palette.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppTheme.sageMuted(0.95) : AppTheme.inkMuted(0.35))
            }
            .padding(14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.nestedGlassFill)
                }
            }
            .premiumGlassCard(cornerRadius: 18)
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
                    .foregroundStyle(AppTheme.iconOnChip)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.iconChipFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(preference.title)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(preference.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppTheme.sageMuted(0.95) : AppTheme.inkMuted(0.35))
            }
            .padding(14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.nestedGlassFill)
                }
            }
            .premiumGlassCard(cornerRadius: 18)
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
                .foregroundStyle(AppTheme.inkMuted(0.65))
                .padding(.leading, 4)

            content()
        }
    }

    private func infoCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageMuted(0.9))
                .padding(.top, 1)

            Text(text)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.inkMuted(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
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
                .foregroundStyle(AppTheme.inkMuted(0.55))

            Text(L10n.Settings.textSizePreviewSample)
                .font(.custom("Poppins-Medium", size: appearance.textSize.previewSize))
                .foregroundStyle(AppTheme.titleOnGlass)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumGlassCard(cornerRadius: 18)
    }

    private func textSizeRow(_ preference: AppTextSizePreference) -> some View {
        let isSelected = appearance.textSize == preference

        return Button {
            appearance.selectTextSize(preference)
        } label: {
            HStack(spacing: 14) {
                Text("Aa")
                    .font(.custom("Poppins-SemiBold", size: preference == .small ? 13 : preference == .medium ? 16 : 19))
                    .foregroundStyle(AppTheme.labelOnLightSurface)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.selectedChipFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(preference.title)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(preference.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppTheme.sageMuted(0.95) : AppTheme.inkMuted(0.35))
            }
            .padding(14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.nestedGlassFill)
                }
            }
            .premiumGlassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func infoCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageMuted(0.9))
                .padding(.top, 1)

            Text(text)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.inkMuted(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
    }
}

struct CountdownFontSettingsView: View {
    @ObservedObject private var appearance = AppearanceStore.shared

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Settings.countdown,
                        subtitle: L10n.Settings.countdownChooserSub
                    )

                    previewCard

                    VStack(spacing: 10) {
                        ForEach(AppCountdownFontPreference.allCases) { preference in
                            fontRow(preference)
                        }
                    }

                    infoCard(L10n.Settings.countdownInfo)
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
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Settings.countdownPreview)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.inkMuted(0.55))

            HStack(spacing: 10) {
                previewTile("128", label: L10n.Dashboard.countdownDays)
                previewTile("04", label: L10n.Dashboard.countdownHours)
                previewTile("21", label: L10n.Dashboard.countdownMinutes)
                previewTile("09", label: L10n.Dashboard.countdownSeconds)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumGlassCard(cornerRadius: 18)
    }

    private func previewTile(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(appearance.countdownFont.font(size: 24))
                .foregroundStyle(AppTheme.labelOnLightSurface)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(label)
                .font(AppFont.medium(9))
                .foregroundStyle(AppTheme.labelOnLightSurface.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.selectedChipFill)
        }
    }

    private func fontRow(_ preference: AppCountdownFontPreference) -> some View {
        let isSelected = appearance.countdownFont == preference

        return Button {
            appearance.selectCountdownFont(preference)
        } label: {
            HStack(spacing: 14) {
                Text("12")
                    .font(preference.font(size: 18))
                    .foregroundStyle(AppTheme.labelOnLightSurface)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.selectedChipFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(preference.title)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(preference.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppTheme.sageMuted(0.95) : AppTheme.inkMuted(0.35))
            }
            .padding(14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.nestedGlassFill)
                }
            }
            .premiumGlassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func infoCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageMuted(0.9))
                .padding(.top, 1)

            Text(text)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.inkMuted(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
    }
}
