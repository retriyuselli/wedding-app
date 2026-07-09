import Foundation

enum APIConfig {
    /// Production API — ganti jika domain deploy berbeda.
    static let productionURL = URL(string: "https://api.weddingapp.co.id/api/v1")!

    #if DEBUG
    /// Physical devices can't reach the Mac's localhost, so they need the Mac's LAN IP instead.
    /// Update this if the Mac's IP changes (check with `ipconfig getifaddr en0` on the Mac).
    /// Start backend with: `php artisan serve --host=0.0.0.0 --port=8000`
    private static let lanHost = "192.168.1.3"

    /// Set `true` untuk memaksa build Debug memakai server production HTTPS.
    static var usesProductionAPI = false

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
