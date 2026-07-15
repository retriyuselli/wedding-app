import SwiftUI

struct SavedVendorsView: View {
    @ObservedObject private var savedStore = SavedVendorsStore.shared

    @State private var vendors: [VendorItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var savedVendors: [VendorItem] {
        vendors
            .filter { savedStore.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.More.savedVendors,
                        subtitle: L10n.More.savedVendorsSub
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    if isLoading && vendors.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if savedVendors.isEmpty {
                        MoreEmptyState(
                            icon: "bookmark",
                            title: L10n.Vendor.savedEmptyTitle,
                            message: L10n.Vendor.savedEmptyMessage
                        )
                    } else {
                        VStack(spacing: 12) {
                            ForEach(savedVendors) { vendor in
                                NavigationLink {
                                    VendorDetailView(slug: vendor.slug)
                                } label: {
                                    SavedVendorRow(
                                        vendor: vendor,
                                        onRemove: { savedStore.toggle(vendor.id) }
                                    )
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
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[Vendor]> = try await APIClient.shared.request("vendors")
            vendors = envelope.data.map { VendorItem(api: $0, isSaved: savedStore.contains($0.id)) }
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}

private struct SavedVendorRow: View {
    let vendor: VendorItem
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(vendor.logoTint)

                if let raw = vendor.logoUrl ?? vendor.coverImageUrl,
                   let url = URL(string: raw) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Image(systemName: vendor.logoSymbol)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    Image(systemName: vendor.logoSymbol)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(vendor.name)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(1)

                Text(vendor.categoryLabel)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))

                Label(vendor.city, systemImage: "mappin")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .labelStyle(.titleAndIcon)
            }

            Spacer(minLength: 0)

            VStack(spacing: 10) {
                Button(action: onRemove) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.lightSage, in: Circle())
                }
                .buttonStyle(.plain)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.28))
            }
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 20)
    }
}
