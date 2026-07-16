import SwiftUI

struct SharedDirectoryView: View {
    @StateObject private var viewModel = SharedDirectoryViewModel()

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.directoryTitle,
                        subtitle: L10n.Privacy.directorySubtitle
                    )

                    if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 8) {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                            Button(L10n.Common.tryAgain) {
                                Task { await viewModel.load() }
                            }
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.sageMuted(0.9))
                        }
                    }

                    if viewModel.isLoading && viewModel.users.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if viewModel.users.isEmpty && viewModel.errorMessage == nil {
                        Text(L10n.Privacy.directoryEmpty)
                            .font(AppFont.regular(14))
                            .foregroundStyle(AppTheme.inkMuted(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .premiumGlassCard(cornerRadius: 18)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.users) { user in
                                NavigationLink {
                                    SharedUserDetailView(userId: user.id)
                                } label: {
                                    directoryRow(user)
                                }
                                .buttonStyle(.plain)
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
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func directoryRow(_ user: SharedDirectoryUser) -> some View {
        HStack(spacing: 14) {
            avatar(for: user)

            VStack(alignment: .leading, spacing: 3) {
                Text(user.name)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.titleOnGlass)
                if let couplePreview = user.couplePreview, !couplePreview.isEmpty {
                    Text(couplePreview)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                        .lineLimit(1)
                } else if let budaya = user.budaya, !budaya.isEmpty {
                    Text(budaya)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.inkMuted(0.4))
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
    }

    @ViewBuilder
    private func avatar(for user: SharedDirectoryUser) -> some View {
        if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholderAvatar(initials: initials(from: user.name))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            placeholderAvatar(initials: initials(from: user.name))
        }
    }

    private func placeholderAvatar(initials: String) -> some View {
        Text(initials)
            .font(AppFont.medium(14))
            .foregroundStyle(AppTheme.iconOnChip)
            .frame(width: 44, height: 44)
            .background(AppTheme.iconChipFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased()
    }
}
