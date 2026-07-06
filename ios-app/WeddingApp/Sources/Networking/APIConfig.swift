import Foundation

enum APIConfig {
    /// Physical devices can't reach the Mac's localhost, so they need the Mac's LAN IP instead.
    /// Update this if the Mac's IP changes (check with `ipconfig getifaddr en0` on the Mac).
    /// Start backend with: `php artisan serve --host=0.0.0.0 --port=8000`
    private static let lanHost = "192.168.1.3"

    static var baseURL: URL {
        #if targetEnvironment(simulator)
        URL(string: "http://127.0.0.1:8000/api/v1")!
        #else
        URL(string: "http://\(lanHost):8000/api/v1")!
        #endif
    }
}
