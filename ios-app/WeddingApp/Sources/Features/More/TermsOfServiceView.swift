import SwiftUI

struct TermsOfServiceView: View {
    @State private var selectedLanguage: PrivacyPolicyLanguage = .indonesian

    private var content: TermsOfServiceLocaleContent {
        TermsOfServiceContent.content(for: selectedLanguage)
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MoreSubpageNavigationHeader(
                        title: content.pageTitle,
                        subtitle: content.lastUpdated
                    )

                    languageChips

                    introCard

                    ForEach(content.sections) { section in
                        sectionCard(section)
                    }

                    contactCard

                    webVersionCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.2), value: selectedLanguage)
    }

    private var languageChips: some View {
        HStack(spacing: 10) {
            ForEach(PrivacyPolicyLanguage.allCases) { language in
                Button {
                    selectedLanguage = language
                } label: {
                    Text(language.chipLabel)
                        .font(AppFont.medium(13))
                        .foregroundStyle(selectedLanguage == language ? .white : AppTheme.sageDark)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background {
                            if selectedLanguage == language {
                                Capsule().fill(AppTheme.sageDark)
                            } else {
                                Capsule()
                                    .fill(Color.white.opacity(0.72))
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                        .overlay {
                            if selectedLanguage != language {
                                Capsule()
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
    }

    private var introCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 52, height: 52)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(content.introTitle)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)

                Text(content.introduction)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumGlassCard(cornerRadius: 20)
    }

    private func sectionCard(_ section: PrivacyPolicySection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.sageDark)

            ForEach(section.paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }

            if !section.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(section.bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(AppTheme.sageDark.opacity(0.65))
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            Text(bullet)
                                .font(AppFont.regular(13))
                                .foregroundStyle(AppTheme.ink.opacity(0.68))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                        }
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumGlassCard(cornerRadius: 20)
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(content.contactTitle)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)

            Text(content.contactDescription)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Link(destination: URL(string: "mailto:\(TermsOfServiceContent.contactEmail)")!) {
                    Label(content.emailButton, systemImage: "envelope.fill")
                        .font(AppFont.medium(13))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                NavigationLink {
                    HelpFAQView()
                } label: {
                    Label(content.helpButton, systemImage: "questionmark.circle")
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 18)
    }

    private var webVersionCard: some View {
        Link(destination: AboutContent.termsURL) {
            HStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 16, weight: .medium))
                Text(content.webVersionLabel)
                    .font(AppFont.medium(13))
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(AppTheme.sageDark)
            .padding(14)
            .premiumGlassCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}
