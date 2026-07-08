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
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(language.label)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.ink)
                    Text(language.isAvailable ? language.nativeSubtitle : L10n.Common.comingSoon)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                Spacer(minLength: 8)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.sageDark)
                } else if !language.isAvailable {
                    Text(L10n.Common.soon)
                        .font(AppFont.medium(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.mist, in: Capsule())
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.ink.opacity(0.2))
                }
            }
            .padding(14)
            .background(
                (isSelected ? AppTheme.lightSage.opacity(0.5) : AppTheme.surface),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(isSelected ? 0.3 : 0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(!language.isAvailable)
        .opacity(language.isAvailable ? 1 : 0.6)
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark.opacity(0.75))

            Text(L10n.Language.info)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
