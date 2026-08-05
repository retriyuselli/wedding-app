import Foundation

@MainActor
final class IndonesiaRegionsStore: ObservableObject {
    static let shared = IndonesiaRegionsStore()

    @Published private(set) var provinces: [String] = []
    @Published private(set) var cities: [String] = []
    @Published private(set) var isLoadingProvinces = false
    @Published private(set) var isLoadingCities = false
    @Published private(set) var loadError: String?

    private var citiesCache: [String: [String]] = [:]

    private init() {}

    func loadProvincesIfNeeded() async {
        guard provinces.isEmpty, !isLoadingProvinces else {
            return
        }

        isLoadingProvinces = true
        loadError = nil
        defer { isLoadingProvinces = false }

        do {
            let envelope: Envelope<[String]> = try await APIClient.shared.request("regions/provinces")
            provinces = envelope.data
        } catch {
            loadError = "Gagal memuat daftar provinsi."
            provinces = Self.fallbackProvinces
        }
    }

    func loadCities(for province: String?) async {
        guard let province, !province.isEmpty, province != VendorFilter.allProvincesLabel else {
            cities = []
            return
        }

        if let cached = citiesCache[province] {
            cities = cached
            return
        }

        isLoadingCities = true
        loadError = nil
        defer { isLoadingCities = false }

        do {
            let envelope: Envelope<[String]> = try await APIClient.shared.request(
                "regions/cities",
                queryItems: [URLQueryItem(name: "province", value: province)]
            )
            citiesCache[province] = envelope.data
            cities = envelope.data
        } catch {
            loadError = "Gagal memuat daftar kota."
            cities = Self.fallbackCities[province] ?? []
        }
    }

    private static let fallbackProvinces: [String] = [
        "Sumatera Selatan",
        "Daerah Khusus Ibukota Jakarta",
        "Jawa Barat",
        "Jawa Timur",
        "Sumatera Utara",
    ]

    private static let fallbackCities: [String: [String]] = [
        "Sumatera Selatan": ["Palembang", "Ogan Ilir", "Banyuasin"],
        "Daerah Khusus Ibukota Jakarta": ["Administrasi Jakarta Pusat", "Administrasi Jakarta Selatan", "Administrasi Jakarta Barat"],
        "Jawa Barat": ["Bandung", "Bekasi", "Bogor"],
        "Jawa Timur": ["Surabaya", "Malang", "Sidoarjo"],
        "Sumatera Utara": ["Medan", "Deli Serdang", "Binjai"],
    ]
}
