import SwiftUI

struct SharedUserDetailView: View {
    @StateObject private var viewModel: SharedUserDetailViewModel

    init(userId: Int) {
        _viewModel = StateObject(wrappedValue: SharedUserDetailViewModel(userId: userId))
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: viewModel.profile?.name ?? L10n.Privacy.sharedProfileTitle,
                        subtitle: viewerRoleLabel
                    )

                    if let profileError = viewModel.profileError {
                        VStack(spacing: 8) {
                            Text(profileError)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                            Button(L10n.Common.tryAgain) {
                                Task { await viewModel.load() }
                            }
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.sageMuted(0.9))
                        }
                    }

                    if viewModel.isLoadingProfile && viewModel.profile == nil {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }

                    if let profile = viewModel.profile {
                        profileCard(profile)
                    }

                    if viewModel.isLoadingExtras {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }

                    sectionCard(
                        title: L10n.Privacy.sharedWedding,
                        error: viewModel.weddingError,
                        isEmpty: viewModel.wedding == nil && viewModel.weddingError == nil
                    ) {
                        if let wedding = viewModel.wedding {
                            weddingContent(wedding)
                        }
                    }

                    sectionCard(
                        title: L10n.Privacy.sharedGuests,
                        error: viewModel.guestsError,
                        isEmpty: viewModel.guests.isEmpty && viewModel.guestsError == nil
                    ) {
                        if !viewModel.guests.isEmpty {
                            guestsContent(viewModel.guests)
                        }
                    }

                    sectionCard(
                        title: L10n.Privacy.sharedBudget,
                        error: viewModel.budgetError,
                        isEmpty: viewModel.budget == nil && viewModel.budgetError == nil
                    ) {
                        if let budget = viewModel.budget {
                            budgetContent(budget)
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

    private var viewerRoleLabel: String {
        guard let role = viewModel.viewerRole else {
            return L10n.Privacy.sharedProfileSubtitle
        }
        switch role {
        case "self": return L10n.Privacy.viewerRoleSelf
        case "couple": return L10n.Privacy.viewerRoleCouple
        case "vendor": return L10n.Privacy.viewerRoleVendor
        case "authenticated": return L10n.Privacy.viewerRoleAuthenticated
        default: return L10n.Privacy.sharedProfileSubtitle
        }
    }

    private func profileCard(_ profile: SharedDirectoryUser) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let couplePreview = profile.couplePreview, !couplePreview.isEmpty {
                Text(couplePreview)
                    .font(AppFont.medium(16))
                    .foregroundStyle(AppTheme.titleOnGlass)
            }
            if let budaya = profile.budaya, !budaya.isEmpty {
                Text(budaya)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.inkMuted(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumGlassCard(cornerRadius: 18)
    }

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        error: String?,
        isEmpty: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.inkMuted(0.7))

            if let error {
                Text(error)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.inkMuted(0.6))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .premiumGlassCard(cornerRadius: 16)
            } else if isEmpty {
                Text(L10n.Privacy.sharedSectionUnavailable)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.inkMuted(0.55))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .premiumGlassCard(cornerRadius: 16)
            } else {
                content()
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .premiumGlassCard(cornerRadius: 16)
            }
        }
    }

    private func weddingContent(_ wedding: SharedWeddingPayload) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            let info = wedding.weddingInfo
            let couple = [info.brideName, info.groomName]
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " & ")

            if !couple.isEmpty {
                Text(couple)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.titleOnGlass)
            }

            if wedding.events.isEmpty {
                Text(L10n.Privacy.sharedNoEvents)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.inkMuted(0.55))
            } else {
                ForEach(wedding.events) { event in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.jenisLabel ?? WeddingEvent.label(for: event.jenisAcara))
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.titleOnGlass)
                        if let date = event.tglAcara, !date.isEmpty {
                            Text(date)
                                .font(AppFont.regular(12))
                                .foregroundStyle(AppTheme.inkMuted(0.55))
                        }
                        if let lokasi = event.lokasiAcara, !lokasi.isEmpty {
                            Text(lokasi)
                                .font(AppFont.regular(12))
                                .foregroundStyle(AppTheme.inkMuted(0.55))
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private func guestsContent(_ guests: [Guest]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Privacy.sharedGuestCount(guests.count))
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.inkMuted(0.6))

            ForEach(guests.prefix(20)) { guest in
                HStack {
                    Text(guest.name)
                        .font(AppFont.regular(14))
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Spacer()
                    Text(guest.rsvpStatus.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                }
            }

            if guests.count > 20 {
                Text(L10n.Privacy.sharedGuestsMore(guests.count - 20))
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.5))
            }
        }
    }

    private func budgetContent(_ payload: SharedBudgetPayload) -> some View {
        let summary = payload.summary
        return VStack(alignment: .leading, spacing: 8) {
            budgetRow(L10n.Privacy.sharedBudgetTotal, CurrencyFormatter.rupiah(summary.totalBudget))
            budgetRow(L10n.Privacy.sharedBudgetSpent, CurrencyFormatter.rupiah(summary.spent))
            budgetRow(L10n.Privacy.sharedBudgetRemaining, CurrencyFormatter.rupiah(summary.remaining))
        }
    }

    private func budgetRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.inkMuted(0.6))
            Spacer()
            Text(value)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.titleOnGlass)
        }
    }
}
