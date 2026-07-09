import Foundation

enum APIResolver {
    enum Source: String {
        case local
        case production
        case forcedProduction
    }

    private(set) static var resolvedBaseURL = APIConfig.productionURL
    private(set) static var source: Source = .production

    private static var didResolve = false
    private static let probeTimeout: TimeInterval = 2

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

        for candidate in APIConfig.localCandidateBaseURLs {
            if await isAPIReachable(at: candidate) {
                resolvedBaseURL = candidate
                source = .local
                logSelection()
                return
            }
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
    private static func logSelection() {
        print("[API] Using \(source.rawValue) base URL: \(resolvedBaseURL.absoluteString)")
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
