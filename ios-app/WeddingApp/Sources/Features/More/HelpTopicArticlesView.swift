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
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: topic.title,
                        subtitle: topic.subtitle
                    )

                    topicSummaryCard

                    searchBar

                    if filteredArticles.isEmpty {
                        MoreEmptyState(
                            icon: "doc.text.magnifyingglass",
                            title: "Tidak ada artikel",
                            message: "Coba kata kunci lain atau kembali ke daftar topik bantuan."
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
                Text("\(articles.count) artikel tersedia")
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text("Panduan lengkap seputar \(topic.title.lowercased())")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.lightSage.opacity(0.45), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.ink.opacity(0.4))

            TextField("Cari artikel...", text: $searchText)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
        }
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

                    Text("\(article.readMinutes) menit baca")
                        .font(AppFont.regular(10))
                        .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.28))
            }
            .padding(14)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HelpArticleDetailView: View {
    let article: HelpArticle

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: article.title,
                        subtitle: "\(article.readMinutes) menit baca · \(article.topic.title)"
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
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var relatedTopicCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.gold)

            Text("Masih butuh bantuan? Hubungi customer support melalui halaman Bantuan & FAQ atau kirim email ke \(HelpContent.supportEmail)")
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
