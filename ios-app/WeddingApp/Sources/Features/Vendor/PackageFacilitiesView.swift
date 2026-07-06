import SwiftUI

struct PackageFacilitiesView: View {
    let sections: [VendorFacilitySection]
    var showsHeader: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if showsHeader {
                Text("FASILITAS")
                    .font(AppFont.semibold(13))
                    .tracking(0.8)
                    .foregroundStyle(AppTheme.sageDark)
            }

            VStack(alignment: .leading, spacing: 18) {
                ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                    VStack(alignment: .leading, spacing: 8) {
                        if shouldShowSectionTitle(section) {
                            Text(section.title.trimmingCharacters(in: .whitespacesAndNewlines))
                                .font(AppFont.semibold(13))
                                .foregroundStyle(AppTheme.sageDark)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                                Text("\(index + 1). \(item)")
                                    .font(AppFont.regular(12))
                                    .foregroundStyle(AppTheme.ink.opacity(0.72))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func shouldShowSectionTitle(_ section: VendorFacilitySection) -> Bool {
        let title = section.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            return false
        }

        if sections.count > 1 {
            return true
        }

        if !showsHeader {
            return true
        }

        return !isGenericFacilitiesTitle(title)
    }

    private func isGenericFacilitiesTitle(_ title: String) -> Bool {
        title
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased() == "fasilitas"
    }
}

struct PackageExclusionsView: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TIDAK TERMASUK")
                .font(AppFont.semibold(13))
                .tracking(0.8)
                .foregroundStyle(AppTheme.sageDark)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Text("\(index + 1). \(item)")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
