import SwiftUI

struct SecuritySummaryView: View {
    @StateObject private var viewModel = PrivacySecurityViewModel()

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: viewModel.summary?.title ?? L10n.Privacy.accountSafe,
                        subtitle: viewModel.summary?.message ?? L10n.Privacy.accountSafeSub
                    )

                    if viewModel.isLoading && viewModel.summary == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.summary == nil {
                        errorState(errorMessage)
                    } else if let summary = viewModel.summary {
                        scoreCard(summary)
                        ForEach(summary.checks) { check in
                            checkRow(check)
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
        .refreshable { await viewModel.retry() }
    }

    private func scoreCard(_ summary: PrivacySecuritySummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Skor keamanan: \(summary.score)%")
                .font(AppFont.medium(16))
                .foregroundStyle(AppTheme.ink)
            Text(summary.status == "secure" ? "Status: Aman" : "Status: Perlu perhatian")
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func checkRow(_ check: PrivacySecurityCheck) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: check.passed ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(check.passed ? AppTheme.sageDark : Color.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(check.label).font(AppFont.medium(14)).foregroundStyle(AppTheme.ink)
                Text(check.detail).font(AppFont.regular(12)).foregroundStyle(AppTheme.ink.opacity(0.5))
            }
            Spacer()
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message).font(AppFont.regular(13)).foregroundStyle(.red)
            Button("Coba lagi") { Task { await viewModel.retry() } }
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
