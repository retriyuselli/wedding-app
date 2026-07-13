import Foundation

enum APIResolver {
    enum Source: String {
        case local
        case production
        case forcedProduction
        case cached
    }

    private(set) static var resolvedBaseURL = APIConfig.productionURL
    private(set) static var source: Source = .production

    private static var resolveTask: Task<Void, Never>?
    private static let probeTimeout: TimeInterval = 1.5
    private static let lastGoodURLKey = "APIResolver.lastGoodBaseURL"

    static func resolveIfNeeded() async {
        if let resolveTask {
            await resolveTask.value
            return
        }

        let task = Task {
            await performResolve()
        }

        resolveTask = task
        await task.value
        resolveTask = nil
    }

    static func invalidateAndResolve() async {
        resolveTask?.cancel()
        resolveTask = nil
        clearCachedBaseURL()
        await resolveIfNeeded()
    }

    #if DEBUG
    static func clearCachedBaseURL() {
        UserDefaults.standard.removeObject(forKey: lastGoodURLKey)
    }
    #else
    static func clearCachedBaseURL() {}
    #endif

    private static func performResolve() async {
        #if DEBUG
        if APIConfig.usesProductionAPI {
            resolvedBaseURL = APIConfig.productionURL
            source = .forcedProduction
            logSelection()
            return
        }

        // Prefer local backend first so Debug always uses the running artisan serve
        // (and new fields like item_html), instead of racing production.
        for localURL in APIConfig.localCandidateBaseURLs {
            if await isAPIReachable(at: localURL) {
                applySelection(localURL, source: .local)
                return
            }
        }

        if let cachedURL = cachedBaseURL(),
           cachedURL != APIConfig.productionURL,
           await isAPIReachable(at: cachedURL) {
            applySelection(cachedURL, source: .cached)
            return
        }

        clearCachedBaseURL()

        if await isAPIReachable(at: APIConfig.productionURL) {
            applySelection(APIConfig.productionURL, source: .production)
            return
        }

        if let localURL = APIConfig.localCandidateBaseURLs.first {
            resolvedBaseURL = localURL
            source = .local
            logSelection()
            return
        }

        resolvedBaseURL = APIConfig.productionURL
        source = .production
        logSelection()
        #else
        resolvedBaseURL = APIConfig.productionURL
        source = .production
        #endif
    }

    #if DEBUG
    private static func applySelection(_ url: URL, source newSource: Source) {
        resolvedBaseURL = url
        source = newSource
        cacheBaseURL(url)
        logSelection()
    }

    private static func logSelection() {
        print("[API] Using \(source.rawValue) base URL: \(resolvedBaseURL.absoluteString)")
    }

    private static func cachedBaseURL() -> URL? {
        guard let rawValue = UserDefaults.standard.string(forKey: lastGoodURLKey) else {
            return nil
        }

        return URL(string: rawValue)
    }

    private static func cacheBaseURL(_ url: URL) {
        UserDefaults.standard.set(url.absoluteString, forKey: lastGoodURLKey)
    }
    #endif

    private static func isAPIReachable(at baseURL: URL) async -> Bool {
        guard let healthURL = healthCheckURL(for: baseURL) else {
            return false
        }

        var request = URLRequest(url: healthURL)
        request.httpMethod = "GET"
        request.timeoutInterval = probeTimeout

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = probeTimeout
        configuration.timeoutIntervalForResource = probeTimeout
        configuration.waitsForConnectivity = false
        let session = URLSession(configuration: configuration)

        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            return (200...299).contains(httpResponse.statusCode)
        } catch {
            return false
        }
    }

    private static func healthCheckURL(for baseURL: URL) -> URL? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }

        components.path = "/up"
        components.query = nil
        components.fragment = nil

        return components.url
    }
}
