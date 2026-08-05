import Foundation
import os

enum APIResolver {
    enum Source: String {
        case local
        case production
        case forcedProduction
        case cached
    }

    private static let probeTimeout: TimeInterval = 1.5
    private static let lastGoodURLKey = "APIResolver.lastGoodBaseURL"

    /// Sync-readable snapshot for `APIConfig.baseURL`. Updated only via scoped locks
    /// (never held across `await`).
    private static let published = OSAllocatedUnfairLock(
        initialState: (url: APIConfig.productionURL, source: Source.production)
    )

    private static let coordinator = ResolveCoordinator()

    static var resolvedBaseURL: URL {
        published.withLock { $0.url }
    }

    static var source: Source {
        published.withLock { $0.source }
    }

    static func resolveIfNeeded() async {
        await coordinator.resolveIfNeeded()
    }

    static func invalidateAndResolve() async {
        await coordinator.invalidateAndResolve()
    }

    #if DEBUG
    static func clearCachedBaseURL() {
        UserDefaults.standard.removeObject(forKey: lastGoodURLKey)
    }
    #else
    static func clearCachedBaseURL() {}
    #endif

    fileprivate static func publish(_ url: URL, source: Source) {
        published.withLock { state in
            state = (url, source)
        }
    }

    fileprivate static func performResolve() async {
        #if DEBUG
        if APIConfig.usesProductionAPI {
            applySelection(APIConfig.productionURL, source: .forcedProduction)
            return
        }

        // Prefer local backend first so Debug always uses the running artisan serve
        // instead of racing production.
        for localURL in APIConfig.localCandidateBaseURLs {
            if Task.isCancelled { return }
            if await isAPIReachable(at: localURL) {
                applySelection(localURL, source: .local)
                return
            }
        }

        if let cachedURL = cachedBaseURL(),
           cachedURL != APIConfig.productionURL {
            if Task.isCancelled { return }
            if await isAPIReachable(at: cachedURL) {
                applySelection(cachedURL, source: .cached)
                return
            }
        }

        clearCachedBaseURL()

        if APIConfig.allowsProductionFallback {
            if Task.isCancelled { return }
            if await isAPIReachable(at: APIConfig.productionURL) {
                applySelection(APIConfig.productionURL, source: .production)
                return
            }
        }

        // Prefer sticking to the local candidate so a down artisan serve fails loudly
        // instead of silently talking to production with a local session token.
        if let localURL = APIConfig.localCandidateBaseURLs.first {
            applySelection(localURL, source: .local, cache: false)
            return
        }

        applySelection(APIConfig.productionURL, source: .production, cache: false)
        #else
        applySelection(APIConfig.productionURL, source: .production, cache: false)
        #endif
    }

    private static func applySelection(_ url: URL, source newSource: Source, cache: Bool = true) {
        publish(url, source: newSource)

        #if DEBUG
        if cache {
            cacheBaseURL(url)
        }
        print("[API] Using \(newSource.rawValue) base URL: \(url.absoluteString)")
        #endif
    }

    #if DEBUG
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
        defer { session.invalidateAndCancel() }

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

/// Serializes resolve work so concurrent API callers share one probe without racing.
private actor ResolveCoordinator {
    private var resolveTask: Task<Void, Never>?
    private var generation = 0

    func resolveIfNeeded() async {
        if let resolveTask {
            await resolveTask.value
            return
        }

        generation &+= 1
        let myGeneration = generation
        let task = Task {
            await APIResolver.performResolve()
        }
        resolveTask = task
        await task.value
        if generation == myGeneration {
            resolveTask = nil
        }
    }

    func invalidateAndResolve() async {
        let previous = resolveTask
        resolveTask = nil
        generation &+= 1
        previous?.cancel()
        APIResolver.clearCachedBaseURL()
        await resolveIfNeeded()
    }
}
