import Foundation

@MainActor
final class VendorCategoriesStore: ObservableObject {
    static let shared = VendorCategoriesStore()

    @Published private(set) var categories: [VendorCategoryInfo] = []
    @Published private(set) var isLoading = false
    @Published private(set) var loadError: String?

    private init() {}

    func loadIfNeeded() async {
        guard categories.isEmpty, !isLoading else {
            return
        }

        await reload()
    }

    func reload() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[VendorCategoryInfo]> = try await APIClient.shared.request("categories")
            categories = envelope.data
        } catch {
            loadError = error.userFacingMessage
        }
    }

    func name(for slug: String) -> String? {
        categories.first(where: { $0.slug == slug })?.name
    }

    func icon(for slug: String) -> String? {
        categories.first(where: { $0.slug == slug })?.icon
    }

    /// Kategori yang punya minimal satu vendor di katalog.
    func categoriesWithVendors(in vendors: [VendorItem]) -> [VendorCategoryInfo] {
        let slugs = Set(vendors.map(\.categorySlug))

        return categories.filter { slugs.contains($0.slug) }
    }
}
