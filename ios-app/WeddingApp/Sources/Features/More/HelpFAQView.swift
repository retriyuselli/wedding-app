import SwiftUI

private struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct HelpFAQView: View {
    @State private var searchText = ""
    @State private var expandedFAQ: UUID?
    @State private var showComingSoon = false

    private static let supportEmail = HelpContent.supportEmail
    private var supportEmail: String { Self.supportEmail }

    private let topics = HelpTopicKind.allCases

    private var faqs: [FAQItem] {
        L10n.Help.faqItems.map { FAQItem(question: $0.question, answer: $0.answer) }
    }

    private var filteredFAQs: [FAQItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return faqs }
        return faqs.filter {
            $0.question.lowercased().contains(query) || $0.answer.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    MoreSubpageNavigationHeader(
                        title: L10n.More.help,
                        subtitle: L10n.More.helpSub
                    )

                    searchBar

                    topicSection

                    faqSection

                    contactSection

                    HelpServiceHoursCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .alert(L10n.Common.comingSoon, isPresented: $showComingSoon) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.Common.comingSoonMessage)
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.ink.opacity(0.4))

            TextField(L10n.Help.searchPlaceholder, text: $searchText)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .premiumGlassCard(cornerRadius: 16)
    }

    // MARK: - Topics

    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Help.topics)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(topics) { topic in
                        topicCard(topic)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func topicCard(_ topic: HelpTopicKind) -> some View {
        NavigationLink {
            HelpTopicArticlesView(topic: topic)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: topic.icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(topic.title)
                    .font(AppFont.medium(11))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.Help.articleCount(topic.articleCount))
                    .font(AppFont.regular(10))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }
            .frame(width: 92, height: 116)
            .padding(.horizontal, 6)
            .premiumGlassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    // MARK: - FAQ

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.Help.popularFaq)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Button {
                    showComingSoon = true
                } label: {
                    HStack(spacing: 3) {
                        Text(L10n.Common.seeAll)
                            .font(AppFont.regular(12))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                }
                .buttonStyle(.plain)
            }

            if filteredFAQs.isEmpty {
                MoreEmptyState(
                    icon: "questionmark.circle",
                    title: L10n.Help.noResultsTitle,
                    message: L10n.Help.noResultsSub
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredFAQs) { faq in
                        faqRow(faq)
                    }
                }
            }
        }
    }

    private func faqRow(_ faq: FAQItem) -> some View {
        let isExpanded = expandedFAQ == faq.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedFAQ = isExpanded ? nil : faq.id
                }
            } label: {
                HStack(spacing: 12) {
                    Text(faq.question)
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.4))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(faq.answer)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .premiumGlassCard(cornerRadius: 16)
    }

    // MARK: - Contact

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Help.needHelp)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.ink)

            VStack(spacing: 0) {
                NavigationLink {
                    HelpCustomerSupportView()
                } label: {
                    contactRow(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: L10n.Help.contactSupport,
                        subtitle: L10n.Help.contactSupportSub
                    )
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 62)

                NavigationLink {
                    HelpSendEmailView()
                } label: {
                    contactRow(
                        icon: "envelope.fill",
                        title: L10n.Help.emailSupport,
                        subtitle: supportEmail
                    )
                }
                .buttonStyle(.plain)
            }
            .premiumGlassCard(cornerRadius: 18)
        }
    }

    private func contactRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 34, height: 34)
                .background(AppTheme.sage.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text(subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
