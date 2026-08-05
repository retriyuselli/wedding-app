import SwiftUI

struct HelpCenterAPIView: View {
    @StateObject private var viewModel = HelpCenterViewModel()

    private var localeCode: String {
        LocalizationManager.shared.isEnglish ? "en" : "id"
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.helpCenter,
                        subtitle: L10n.Privacy.helpCenterSub
                    )

                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField(L10n.Help.searchHelpPlaceholder, text: $viewModel.searchText)
                            .font(AppFont.regular(14))
                    }
                    .padding(14)
                    .premiumListRow(cornerRadius: 16)

                    if let errorMessage = viewModel.errorMessage, viewModel.payload == nil {
                        VStack(spacing: 10) {
                            Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                            Button(L10n.Common.tryAgain) {
                                Task { await viewModel.retry(locale: localeCode) }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if viewModel.isLoading && viewModel.payload == nil {
                        ProgressView()
                            .tint(AppTheme.titleOnBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }

                    if let payload = viewModel.payload {
                        Text(L10n.Help.faqSection)
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.mutedOnBackground)

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
                            .premiumListRow(cornerRadius: 16)
                        }

                        Text(L10n.Help.topicsSection)
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.mutedOnBackground)

                        ForEach(payload.topics) { topic in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(topic.title).font(AppFont.medium(14)).foregroundStyle(AppTheme.ink)
                                Text(topic.description)
                                    .font(AppFont.regular(12))
                                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .premiumListRow(cornerRadius: 16)
                        }

                        if let contacts = payload.contactMethods {
                            Text(L10n.Help.contactsSection)
                                .font(AppFont.medium(15))
                                .foregroundStyle(AppTheme.mutedOnBackground)

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
        .premiumListRow(cornerRadius: 16)
    }
}
