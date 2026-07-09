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

    private static var didResolve = false
    private static let probeTimeout: TimeInterval = 1.5
    private static let lastGoodURLKey = "APIResolver.lastGoodBaseURL"

    static func resolveIfNeeded() async {
        guard !didResolve else {
            return
        }

        defer { didResolve = true }

        #if DEBUG
        if APIConfig.usesProductionAPI {
            resolvedBaseURL = APIConfig.productionURL
            source = .forcedProduction
            logSelection()
            return
        }

        if let cachedURL = cachedBaseURL(), await isAPIReachable(at: cachedURL) {
            resolvedBaseURL = cachedURL
            source = .cached
            logSelection()
            return
        }

        let candidates = APIConfig.localCandidateBaseURLs + [APIConfig.productionURL]

        if let reachableURL = await firstReachableURL(from: candidates) {
            applySelection(reachableURL)
            return
        }

        resolvedBaseURL = APIConfig.localCandidateBaseURLs.first ?? APIConfig.productionURL
        source = .local
        logSelection()
        #else
        resolvedBaseURL = APIConfig.productionURL
        source = .production
        #endif
    }

    static func invalidateAndResolve() async {
        didResolve = false
        await resolveIfNeeded()
    }

    #if DEBUG
    private static func applySelection(_ url: URL) {
        resolvedBaseURL = url
        source = url == APIConfig.productionURL ? .production : .local
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

    private static func firstReachableURL(from candidates: [URL]) async -> URL? {
        await withTaskGroup(of: URL?.self) { group in
            for candidate in candidates {
                group.addTask {
                    await isAPIReachable(at: candidate) ? candidate : nil
                }
            }

            for await result in group {
                if let url = result {
                    group.cancelAll()
                    return url
                }
            }

            return nil
        }
    }

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
