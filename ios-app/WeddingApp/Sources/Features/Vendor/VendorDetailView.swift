import SwiftUI

struct VendorDetailView: View {
    let slug: String

    @Environment(\.dismiss) private var dismiss

    @State private var vendor: Vendor?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPackage: VendorPackage?
    @State private var showAllPackages = false

    private let packageGridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    private var item: VendorItem? {
        guard let vendor else { return nil }
        return VendorItem(api: vendor)
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            if isLoading && vendor == nil {
                ProgressView()
            } else if let item, let vendor {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        vendorHero(item)
                        aboutSection(vendor)
                        contactSection(vendor)
                        packagesSection(vendor.packages ?? [], vendor: vendor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            } else {
                errorState
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task(id: slug) { await load() }
        .refreshable { await load() }
        .navigationDestination(item: $selectedPackage) { package in
            VendorPackageDetailView(
                package: package,
                vendorName: vendor?.name ?? "",
                city: vendor?.city ?? ""
            )
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.8))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.top, 4)
    }

    private func vendorHero(_ item: VendorItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(item.logoTint)
                        .frame(width: 64, height: 64)

                    if let logoUrl = item.logoUrl, let url = URL(string: logoUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Image(systemName: item.logoSymbol)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: item.logoSymbol)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(item.name)
                            .font(AppFont.semibold(20))
                            .foregroundStyle(AppTheme.sageDark)

                        if item.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.sageDark)
                        }
                    }

                    Text(item.categoryLabel)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))

                    Label("\(item.city), \(item.province)", systemImage: "mappin")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                }

                Spacer(minLength: 0)
            }

            if item.packagesCount > 0, let startingPrice = item.startingPrice {
                HStack(spacing: 8) {
                    infoChip("\(item.packagesCount) Paket")
                    infoChip("Dari \(CurrencyFormatter.rupiahShort(startingPrice))")
                    if item.isFeatured {
                        infoChip("Unggulan")
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func aboutSection(_ vendor: Vendor) -> some View {
        Group {
            if let description = vendor.description, !description.isEmpty {
                sectionCard("Tentang Vendor") {
                    Text(description)
                        .font(AppFont.regular(13))
                        .foregroundStyle(AppTheme.ink.opacity(0.72))
                        .lineSpacing(4)
                }
            }
        }
    }

    private func contactSection(_ vendor: Vendor) -> some View {
        sectionCard("Kontak") {
            VStack(alignment: .leading, spacing: 10) {
                if let phone = vendor.phone, !phone.isEmpty {
                    contactRow(
                        icon: "phone.fill",
                        text: phone,
                        url: Self.phoneURL(phone)
                    )
                }
                if let email = vendor.email, !email.isEmpty {
                    contactRow(
                        icon: "envelope.fill",
                        text: email,
                        url: URL(string: "mailto:\(email)")
                    )
                }
                if let instagram = vendor.instagram, !instagram.isEmpty {
                    contactRow(
                        icon: "camera.fill",
                        text: instagram,
                        url: Self.instagramURL(instagram)
                    )
                }
                if let website = vendor.website, !website.isEmpty {
                    contactRow(
                        icon: "globe",
                        text: website,
                        url: Self.websiteURL(website)
                    )
                }
                if let address = vendor.address, !address.isEmpty {
                    contactRow(
                        icon: "mappin.circle.fill",
                        text: address,
                        url: Self.mapsURL(address)
                    )
                }
            }
        }
    }

    private func packagesSection(_ packages: [VendorPackage], vendor: Vendor) -> some View {
        let visibleLimit = 4
        let visiblePackages = showAllPackages || packages.count <= visibleLimit
            ? packages
            : Array(packages.prefix(visibleLimit))
        let remainingCount = max(packages.count - visibleLimit, 0)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Paket")
                    .font(AppFont.semibold(16))
                    .foregroundStyle(AppTheme.ink)

                Spacer(minLength: 8)

                if packages.count > visibleLimit {
                    Button(showAllPackages ? "Tutup" : "Lihat") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAllPackages.toggle()
                        }
                    }
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.peachDark)
                }
            }

            if packages.isEmpty {
                Text("Belum ada paket tersedia.")
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                    }
            } else {
                LazyVGrid(columns: packageGridColumns, spacing: 18) {
                    ForEach(visiblePackages) { package in
                        Button {
                            selectedPackage = package
                        } label: {
                            VendorPackageGridCard(
                                package: package,
                                city: vendor.city ?? "",
                                vendorName: vendor.name
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !showAllPackages && remainingCount > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAllPackages = true
                        }
                    } label: {
                        Text("+\(remainingCount) paket lainnya")
                            .font(AppFont.semibold(13))
                            .foregroundStyle(AppTheme.peachDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.softPeach, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var errorState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(AppTheme.ink.opacity(0.25))

            Text(errorMessage ?? "Vendor tidak ditemukan.")
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .multilineTextAlignment(.center)

            Button("Coba Lagi") {
                Task { await load() }
            }
            .font(AppFont.medium(13))
            .foregroundStyle(AppTheme.sageDark)
        }
        .padding(24)
    }

    private func sectionCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.semibold(16))
                .foregroundStyle(AppTheme.sageDark)

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                }
        }
    }

    private func infoChip(_ text: String) -> some View {
        Text(text)
            .font(AppFont.medium(11))
            .foregroundStyle(AppTheme.sageDark)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.lightSage, in: Capsule())
    }

    private func contactRow(icon: String, text: String, url: URL? = nil) -> some View {
        Group {
            if let url {
                Link(destination: url) {
                    contactRowContent(icon: icon, text: text, isTappable: true)
                }
            } else {
                contactRowContent(icon: icon, text: text, isTappable: false)
            }
        }
    }

    private func contactRowContent(icon: String, text: String, isTappable: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 18)
                .padding(.top, 2)

            Text(text)
                .font(AppFont.regular(13))
                .foregroundStyle(isTappable ? AppTheme.sageDark : AppTheme.ink.opacity(0.72))
                .underline(isTappable, color: AppTheme.sageDark.opacity(0.35))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isTappable {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.3))
                    .padding(.top, 2)
            }
        }
    }

    private static func phoneURL(_ phone: String) -> URL? {
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel:\(digits)")
    }

    private static func instagramURL(_ handle: String) -> URL? {
        let trimmed = handle.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }

        let username = trimmed
            .replacingOccurrences(of: "@", with: "")
            .replacingOccurrences(of: "https://instagram.com/", with: "")
            .replacingOccurrences(of: "https://www.instagram.com/", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !username.isEmpty else { return nil }
        return URL(string: "https://instagram.com/\(username)")
    }

    private static func websiteURL(_ website: String) -> URL? {
        let trimmed = website.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(trimmed)")
    }

    private static func mapsURL(_ address: String) -> URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [URLQueryItem(name: "q", value: address)]
        return components?.url
    }

    private func load() async {
        guard !slug.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            vendor = nil
            errorMessage = "Vendor tidak valid."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<Vendor> = try await APIClient.shared.request("vendors/\(slug)")
            vendor = envelope.data
            selectedPackage = nil
            showAllPackages = false
        } catch {
            vendor = nil
            errorMessage = error.userFacingMessage
        }
    }
}

private struct VendorPackageGridCard: View {
    let package: VendorPackage
    let city: String
    let vendorName: String

    private let imageCornerRadius: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                packageImage

                if !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(city)
                        .font(AppFont.medium(10))
                        .foregroundStyle(AppTheme.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.96), in: Capsule())
                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                        .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(package.name)
                    .font(AppFont.semibold(13))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let price = package.priceValue {
                    Text(CurrencyFormatter.rupiah(price))
                        .font(AppFont.semibold(14))
                        .foregroundStyle(AppTheme.peachDark)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(vendorName)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.42))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var packageImage: some View {
        let shape = RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)

        Color.clear
            .aspectRatio(3 / 4, contentMode: .fit)
            .overlay {
                Group {
                    if let coverImageUrl = package.coverImageUrl, let url = URL(string: coverImageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                placeholderImage
                            case .empty:
                                ZStack {
                                    placeholderImage
                                    ProgressView()
                                        .tint(AppTheme.peachDark)
                                }
                            @unknown default:
                                placeholderImage
                            }
                        }
                    } else {
                        placeholderImage
                    }
                }
            }
            .clipShape(shape)
            .overlay {
                shape.stroke(AppTheme.sage.opacity(0.06), lineWidth: 1)
            }
    }

    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.softPeach, AppTheme.mist],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "photo")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
    }
}

private struct VendorPackageDetailView: View {
    let package: VendorPackage
    let vendorName: String
    let city: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    vendorHeader
                    VendorPackageCard(package: package)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.8))
            }
            .buttonStyle(.plain)

            Text(package.name)
                .font(AppFont.semibold(16))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    private var vendorHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(vendorName)
                    .font(AppFont.semibold(15))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                if !city.isEmpty {
                    Text(city)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct VendorPackageCard: View {
    let package: VendorPackage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(package.name)
                                .font(AppFont.semibold(15))
                                .foregroundStyle(AppTheme.ink)

                            if package.isFeatured {
                                Text("Unggulan")
                                    .font(AppFont.medium(10))
                                    .foregroundStyle(AppTheme.sageDark)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.lightSage, in: Capsule())
                            }
                        }

                        if let label = package.priceTypeLabel, package.priceValue != nil {
                            Text(label)
                                .font(AppFont.regular(11))
                                .foregroundStyle(AppTheme.ink.opacity(0.45))
                        }
                    }

                    Spacer(minLength: 8)

                    if let price = package.priceValue {
                        Text(CurrencyFormatter.rupiah(price))
                            .font(AppFont.semibold(14))
                            .foregroundStyle(AppTheme.peachDark)
                    }
                }

                if let description = package.description, !description.isEmpty {
                    Text(description)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.62))
                        .lineSpacing(3)
                }

                HStack(spacing: 8) {
                    if let min = package.capacityMin, let max = package.capacityMax {
                        metaLabel("person.2.fill", "\(min)–\(max) pax")
                    } else if let max = package.capacityMax {
                        metaLabel("person.2.fill", "≤ \(max) pax")
                    }

                    if let hours = package.durationHours {
                        metaLabel("clock.fill", "\(hours) jam")
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.mist.opacity(0.45), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            // Prefer structured sections (numbered rows). HTML is fallback inside the view.
            if !package.displaySections.isEmpty || !(package.itemHtml?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
                PackageFacilitiesView(
                    sections: package.displaySections,
                    itemHtml: package.itemHtml,
                    showsHeader: true
                )
            }

            if !package.displayExclusions.isEmpty {
                PackageExclusionsView(items: package.displayExclusions)
            }
        }
    }

    private func metaLabel(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(AppFont.regular(10))
        }
        .foregroundStyle(AppTheme.ink.opacity(0.5))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.white.opacity(0.7), in: Capsule())
    }
}
