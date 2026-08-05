import SwiftUI

struct DataExportView: View {
    @StateObject private var viewModel = DataExportViewModel()
    @State private var showShare = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.downloadData,
                        subtitle: L10n.Privacy.downloadDataSub
                    )

                    Text(L10n.Privacy.exportBlurb)
                        .font(AppFont.regular(13))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                        Button(L10n.Common.tryAgain) { Task { await viewModel.retry() } }
                    }

                    Button {
                        Task {
                            await viewModel.export()
                            if viewModel.exportFileURL != nil {
                                showSuccess = true
                                showShare = true
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading { ProgressView().tint(.white) }
                            Text(viewModel.isLoading ? L10n.Privacy.exportPreparing : L10n.Privacy.exportDownload)
                                .font(AppFont.medium(15))
                        }
                        .foregroundStyle(AppTheme.primaryActionForeground(enabled: !viewModel.isLoading))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            AppTheme.primaryActionFill(enabled: !viewModel.isLoading),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    }
                    .disabled(viewModel.isLoading)

                    if let url = viewModel.exportFileURL {
                        ShareLink(item: url) {
                            Label(L10n.Privacy.exportShare, systemImage: "square.and.arrow.up")
                                .font(AppFont.medium(14))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .premiumListRow(cornerRadius: 16)
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
        .alert(L10n.Common.success, isPresented: $showSuccess) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
}
