import Foundation

enum APIConfig {
    /// Production API — ganti jika domain deploy berbeda.
    static let productionURL = URL(string: "https://weddingapp.co.id/api/v1")!

    #if DEBUG
    /// UserDefaults override key for physical-device LAN host.
    /// Example: `UserDefaults.standard.set("192.168.1.13", forKey: APIConfig.lanHostDefaultsKey)`
    static let lanHostDefaultsKey = "APIConfig.lanHost"

    /// Fallback Mac LAN IP when no UserDefaults override is set.
    /// Check with `ipconfig getifaddr en0` on the Mac, then either update this
    /// or set `lanHostDefaultsKey` without rebuilding.
    /// Start backend with: `php artisan serve --host=0.0.0.0 --port=8000`
    private static let defaultLanHost = "192.168.1.13"

    static var lanHost: String {
        if let override = UserDefaults.standard.string(forKey: lanHostDefaultsKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !override.isEmpty {
            return override
        }
        return defaultLanHost
    }

    /// Set `true` untuk memaksa build Debug memakai server production HTTPS.
    static var usesProductionAPI = false

    /// When `false` (default), Debug stays on the local candidate if `/up` fails
    /// instead of silently falling back to production (avoids token/data mixups).
    /// Set `true` only when you intentionally want production as a Debug fallback.
    static var allowsProductionFallback = false

    static var localCandidateBaseURLs: [URL] {
        #if targetEnvironment(simulator)
        [URL(string: "http://127.0.0.1:8000/api/v1")!]
        #else
        [URL(string: "http://\(lanHost):8000/api/v1")!]
        #endif
    }
    #endif

    static var baseURL: URL {
        APIResolver.resolvedBaseURL
    }
}
