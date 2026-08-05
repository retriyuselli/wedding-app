import SwiftUI

struct HelpTopicArticlesView: View {
    let topic: HelpTopicKind

    @State private var searchText = ""

    private var articles: [HelpArticle] {
        HelpContent.articles(for: topic)
    }

    private var filteredArticles: [HelpArticle] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return articles }
        return articles.filter {
            $0.title.lowercased().contains(query) || $0.summary.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: topic.title,
                        subtitle: topic.subtitle
                    )

                    topicSummaryCard

                    searchBar

                    if filteredArticles.isEmpty {
                        MoreEmptyState(
                            icon: "doc.text.magnifyingglass",
                            title: L10n.Help.articlesEmptyTitle,
                            message: L10n.Help.articlesEmptyMessage
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(filteredArticles) { article in
                                articleRow(article)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topicSummaryCard: some View {
        HStack(spacing: 14) {
            Image(systemName: topic.icon)
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 52, height: 52)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Help.articlesAvailable(articles.count))
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Help.articlesGuide(topic.title.lowercased()))
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumListRow(cornerRadius: 20)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.ink.opacity(0.4))

            TextField(L10n.Help.articlesSearchPlaceholder, text: $searchText)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .premiumListRow(cornerRadius: 16)
    }

    private func articleRow(_ article: HelpArticle) -> some View {
        NavigationLink {
            HelpArticleDetailView(article: article)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "doc.text")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(article.summary)
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(L10n.Help.readMinutes(article.readMinutes))
                        .font(AppFont.regular(10))
                        .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.28))
            }
            .padding(14)
            .premiumListRow(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

struct HelpArticleDetailView: View {
    let article: HelpArticle

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: article.title,
                        subtitle: L10n.Help.readMinutesTopic(article.readMinutes, article.topic.title)
                    )

                    articleBodyCard

                    relatedTopicCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var articleBodyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(article.summary)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            Text(article.body)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink.opacity(0.7))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumListRow(cornerRadius: 20)
    }

    private var relatedTopicCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.gold)

            Text(L10n.Help.stillNeedHelp(HelpContent.supportEmail))
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumListRow(cornerRadius: 16)
    }
}
