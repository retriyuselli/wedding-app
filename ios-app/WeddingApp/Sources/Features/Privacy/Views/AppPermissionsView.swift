import SwiftUI

struct AppPermissionsView: View {
    @StateObject private var viewModel = AppPermissionsViewModel()
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.permissions,
                        subtitle: L10n.Privacy.permissionsSub
                    )

                    if let errorMessage = viewModel.errorMessage, viewModel.permissions.isEmpty {
                        VStack(spacing: 10) {
                            Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                            Button(L10n.Common.tryAgain) { Task { await viewModel.retry() } }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if viewModel.isLoading && viewModel.permissions.isEmpty {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
                    }

                    ForEach(viewModel.permissions) { row in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(row.item.title).font(AppFont.medium(14)).foregroundStyle(AppTheme.ink)
                                Text(row.item.description)
                                    .font(AppFont.regular(12))
                                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                            }
                            Spacer()
                            Text(row.statusLabel)
                                .font(AppFont.medium(12))
                                .foregroundStyle(row.isGranted ? AppTheme.sageDark : Color.orange)
                        }
                        .padding(14)
                        .premiumGlassCard(cornerRadius: 16)
                    }

                    Button {
                        viewModel.openSystemSettings()
                        showSuccess = true
                    } label: {
                        Text(L10n.Privacy.openIosSettings)
                            .font(AppFont.medium(15))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(.white)
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
        .refreshable { await viewModel.retry() }
        .alert(L10n.Common.ok, isPresented: $showSuccess) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
}
