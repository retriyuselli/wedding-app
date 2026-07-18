import SwiftUI

struct AboutWeddingAppView: View {
    @State private var showReviewUnavailableAlert = false
    @Environment(\.openURL) private var openURL

    private var appVersionLabel: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return L10n.About.version(version, build)
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    MoreSubpageNavigationHeader(
                        title: L10n.More.about,
                        subtitle: L10n.More.aboutSub
                    )

                    heroCard

                    aboutSection

                    informationSection

                    followUsSection

                    footerCopyright
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .alert(L10n.About.reviewsUnavailableTitle, isPresented: $showReviewUnavailableAlert) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.About.reviewsUnavailableMessage)
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    Image("AboutAppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Auth.appName)
                            .font(AppFont.medium(18))
                            .foregroundStyle(AppTheme.sageDark)
                        Text(appVersionLabel)
                            .font(AppFont.regular(12))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                    }

                    Spacer(minLength: 0)
                }

                Text(AboutContent.heroDescription)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .premiumGlassCard(cornerRadius: 22)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(L10n.About.sectionAbout)

            VStack(spacing: 0) {
                ForEach(AboutContent.highlights.indices, id: \.self) { index in
                    let item = AboutContent.highlights[index]
                    aboutHighlightRow(item)

                    if index < AboutContent.highlights.count - 1 {
                        Divider()
                            .padding(.leading, 58)
                    }
                }
            }
            .padding(.vertical, 4)
            .premiumGlassCard(cornerRadius: 20)
        }
    }

    private func aboutHighlightRow(_ item: AboutHighlight) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: item.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 38, height: 38)
                .background(AppTheme.lightSage, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text(item.description)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Information

    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(L10n.About.sectionInfo)

            VStack(spacing: 0) {
                infoValueRow(icon: "building.2", title: L10n.About.rowDeveloper, value: AboutContent.developerName)

                Divider().padding(.leading, 58)

                infoLinkRow(icon: "globe", title: L10n.About.rowWebsite, value: AboutContent.website, url: AboutContent.websiteURL)

                Divider().padding(.leading, 58)

                infoMailRow(icon: "envelope", title: L10n.About.rowEmail, value: AboutContent.email)

                Divider().padding(.leading, 58)

                Button {
                    openAppStoreReviews()
                } label: {
                    infoTrailingRow(icon: "star", title: L10n.About.rowReviews, trailing: nil)
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 58)

                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    infoTrailingRow(icon: "shield", title: L10n.About.rowPrivacy, trailing: nil)
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 58)

                NavigationLink {
                    TermsOfServiceView()
                } label: {
                    infoTrailingRow(icon: "doc.text", title: L10n.About.rowTerms, trailing: nil)
                }
                .buttonStyle(.plain)
            }
            .premiumGlassCard(cornerRadius: 20)
        }
    }

    private func infoValueRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            infoIcon(icon)

            Text(title)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)

            Spacer(minLength: 8)

            Text(value)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func infoLinkRow(icon: String, title: String, value: String, url: URL) -> some View {
        Link(destination: url) {
            infoTrailingRow(icon: icon, title: title, trailing: value)
        }
        .buttonStyle(.plain)
    }

    private func infoMailRow(icon: String, title: String, value: String) -> some View {
        Link(destination: URL(string: "mailto:\(value)")!) {
            infoTrailingRow(icon: icon, title: title, trailing: value)
        }
        .buttonStyle(.plain)
    }

    private func infoNavigationRow(icon: String, title: String, url: URL) -> some View {
        Link(destination: url) {
            infoTrailingRow(icon: icon, title: title, trailing: nil)
        }
        .buttonStyle(.plain)
    }

    private func openAppStoreReviews() {
        guard let url = AboutContent.appStoreWriteReviewURL else {
            showReviewUnavailableAlert = true
            return
        }
        openURL(url)
    }

    private func infoTrailingRow(icon: String, title: String, trailing: String?) -> some View {
        HStack(spacing: 14) {
            infoIcon(icon)

            Text(title)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)

            Spacer(minLength: 8)

            if let trailing {
                Text(trailing)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(1)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private func infoIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(AppTheme.sageDark)
            .frame(width: 34, height: 34)
            .background(AppTheme.sage.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Social

    private var followUsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(L10n.About.sectionFollow)

            HStack(spacing: 10) {
                ForEach(AboutContent.socialLinks) { social in
                    Link(destination: social.url) {
                        AboutSocialBrandIcon(brand: social.brand)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .premiumGlassCard(cornerRadius: 16)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(social.name)
                }
            }
        }
    }

    // MARK: - Footer

    private var footerCopyright: some View {
        VStack(spacing: 4) {
            Text("© \(AboutContent.copyrightYear) \(L10n.Auth.appName)")
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
            Text(L10n.About.rights)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppFont.medium(15))
            .foregroundStyle(AppTheme.ink.opacity(0.72))
            .padding(.leading, 2)
    }
}

private struct AboutSocialBrandIcon: View {
    let brand: AboutSocialBrand

    var body: some View {
        Group {
            switch brand {
            case .instagram:
                InstagramBrandIcon()
            case .tiktok:
                Image(systemName: "music.note")
            case .youtube:
                Image(systemName: "play.rectangle.fill")
            }
        }
        .font(.system(size: 18, weight: .medium))
        .foregroundStyle(AppTheme.sageDark)
        .frame(width: 42, height: 42)
        .background(AppTheme.lightSage, in: Circle())
    }
}

private struct InstagramBrandIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5.5, style: .continuous)
                .stroke(lineWidth: 1.8)

            Circle()
                .stroke(lineWidth: 1.8)
                .frame(width: 11, height: 11)

            Circle()
                .frame(width: 2.2, height: 2.2)
                .offset(x: 5.5, y: -5.5)
        }
        .frame(width: 20, height: 20)
    }
}
