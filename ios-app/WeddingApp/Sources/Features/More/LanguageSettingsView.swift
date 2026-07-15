import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject private var store = LanguageStore.shared

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Language.title,
                        subtitle: L10n.Language.subtitle
                    )

                    VStack(spacing: 10) {
                        ForEach(AppLanguage.allCases) { language in
                            languageRow(language)
                        }
                    }

                    infoCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        let isSelected = store.selected == language

        return Button {
            store.select(language)
        } label: {
            HStack(spacing: 14) {
                Text(language.flag)
                    .font(.system(size: 26))
                    .frame(width: 44, height: 44)
                    .background(AppTheme.iconChipFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(language.label)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(language.isAvailable ? language.nativeSubtitle : L10n.Common.comingSoon)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                }

                Spacer(minLength: 8)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.sageMuted(0.95))
                } else if !language.isAvailable {
                    Text(L10n.Common.soon)
                        .font(AppFont.medium(11))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.chipIdleFill, in: Capsule())
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.inkMuted(0.35))
                }
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
        .disabled(!language.isAvailable)
        .opacity(language.isAvailable ? 1 : 0.6)
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageMuted(0.9))

            Text(L10n.Language.info)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.inkMuted(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }
}
