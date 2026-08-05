import Foundation

struct VendorFilterCatalog {
    let vendors: [VendorItem]

    var provinces: [String] {
        uniqueSorted(vendors.map(\.province).filter { !$0.isEmpty && $0 != "—" })
    }

    func cities(for province: String?) -> [String] {
        let source: [VendorItem]
        if let province, province != VendorFilter.allProvincesLabel {
            source = vendors.filter { $0.province == province }
        } else {
            source = vendors
        }

        return uniqueSorted(source.map(\.city).filter { !$0.isEmpty && $0 != "—" })
    }

    var categorySlugs: Set<String> {
        Set(vendors.map(\.categorySlug))
    }

    private func uniqueSorted(_ values: [String]) -> [String] {
        Array(Set(values)).sorted()
    }
}
