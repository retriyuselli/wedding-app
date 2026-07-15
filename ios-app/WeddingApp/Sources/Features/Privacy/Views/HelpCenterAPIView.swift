import SwiftUI

struct HelpCenterAPIView: View {
    @StateObject private var viewModel = HelpCenterViewModel()

    private var localeCode: String {
        LocalizationManager.shared.isEnglish ? "en" : "id"
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.helpCenter,
                        subtitle: L10n.Privacy.helpCenterSub
                    )

                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Cari bantuan", text: $viewModel.searchText)
                            .font(AppFont.regular(14))
                    }
                    .padding(14)
                    .premiumGlassCard(cornerRadius: 16)

                    if let errorMessage = viewModel.errorMessage, viewModel.payload == nil {
                        VStack(spacing: 10) {
                            Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                            Button("Coba lagi") {
                                Task { await viewModel.retry(locale: localeCode) }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if viewModel.isLoading && viewModel.payload == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
                    }

                    if let payload = viewModel.payload {
                        Text("FAQ")
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.ink.opacity(0.6))

                        ForEach(viewModel.filteredFAQs) { faq in
                            DisclosureGroup {
                                Text(faq.answer)
                                    .font(AppFont.regular(13))
                                    .foregroundStyle(AppTheme.ink.opacity(0.65))
                                    .padding(.top, 6)
                            } label: {
                                Text(faq.question)
                                    .font(AppFont.medium(14))
                                    .foregroundStyle(AppTheme.ink)
                            }
                            .padding(14)
                            .premiumGlassCard(cornerRadius: 16)
                        }

                        Text("Topik")
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.ink.opacity(0.6))

                        ForEach(payload.topics) { topic in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(topic.title).font(AppFont.medium(14)).foregroundStyle(AppTheme.ink)
                                Text(topic.description)
                                    .font(AppFont.regular(12))
                                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .premiumGlassCard(cornerRadius: 16)
                        }

                        if let contacts = payload.contactMethods {
                            Text("Kontak")
                                .font(AppFont.medium(15))
                                .foregroundStyle(AppTheme.ink.opacity(0.6))

                            ForEach(contacts) { method in
                                if let url = URL(string: method.href), method.external {
                                    Link(destination: url) {
                                        contactRow(method)
                                    }
                                } else {
                                    contactRow(method)
                                }
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
        .task { await viewModel.load(locale: localeCode) }
        .refreshable { await viewModel.retry(locale: localeCode) }
    }

    private func contactRow(_ method: HelpCenterContactMethod) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(method.title).font(AppFont.medium(14)).foregroundStyle(AppTheme.ink)
                Text(method.subtitle).font(AppFont.regular(12)).foregroundStyle(AppTheme.ink.opacity(0.5))
            }
            Spacer()
            Text(method.action).font(AppFont.medium(12)).foregroundStyle(AppTheme.sageDark)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }
}
