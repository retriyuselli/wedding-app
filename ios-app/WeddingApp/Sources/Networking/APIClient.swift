import Foundation

final class APIClient {
    static let shared = APIClient()

    private init() {}

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 45
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()

    private static let dateFormatters: [DateFormatter] = {
        let iso = DateFormatter()
        iso.locale = Locale(identifier: "en_US_POSIX")
        iso.timeZone = TimeZone(identifier: "UTC")
        iso.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"

        let simple = DateFormatter()
        simple.locale = Locale(identifier: "en_US_POSIX")
        simple.timeZone = TimeZone(identifier: "UTC")
        simple.dateFormat = "yyyy-MM-dd"

        return [iso, simple]
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            for formatter in APIClient.dateFormatters {
                if let date = formatter.date(from: value) {
                    return date
                }
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognized date: \(value)")
        }
        return decoder
    }()

    func request<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        json: [String: Any]? = nil
    ) async throws -> Response {
        let (data, httpResponse) = try await send(path: path, method: method, queryItems: queryItems, json: json)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw errorFromResponse(path: path, statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            #if DEBUG
            print("API decode error [\(path)]: \(error)")
            #endif
            throw APIError.decoding(String(describing: error))
        }
    }

    func requestNoContent(
        _ path: String,
        method: String = "DELETE",
        queryItems: [URLQueryItem]? = nil,
        json: [String: Any]? = nil
    ) async throws {
        let (data, httpResponse) = try await send(path: path, method: method, queryItems: queryItems, json: json)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw errorFromResponse(path: path, statusCode: httpResponse.statusCode, data: data)
        }
    }

    func uploadMultipart<Response: Decodable>(
        _ path: String,
        method: String = "POST",
        fields: [String: String],
        fileFieldName: String = "proof",
        fileName: String,
        mimeType: String,
        fileData: Data
    ) async throws -> Response {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        for (key, value) in fields {
            body.appendFormField(name: key, value: value, boundary: boundary)
        }

        body.appendFileField(
            name: fileFieldName,
            fileName: fileName,
            mimeType: mimeType,
            fileData: fileData,
            boundary: boundary
        )
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let (data, httpResponse) = try await send(
            path: path,
            method: method,
            multipartBody: body,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )

        guard (200...299).contains(httpResponse.statusCode) else {
            throw errorFromResponse(path: path, statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            #if DEBUG
            print("API decode error [\(path)]: \(error)")
            #endif
            throw APIError.decoding(String(describing: error))
        }
    }

    /// Downloads a binary file (e.g. Excel template) and returns its bytes plus a suggested file name.
    func downloadFile(
        _ path: String,
        method: String = "GET",
        fallbackFileName: String
    ) async throws -> (data: Data, fileName: String) {
        let (data, httpResponse) = try await send(
            path: path,
            method: method,
            accept: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/octet-stream,*/*"
        )

        guard (200...299).contains(httpResponse.statusCode) else {
            throw errorFromResponse(path: path, statusCode: httpResponse.statusCode, data: data)
        }

        let contentType = (httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "").lowercased()
        if contentType.contains("application/json") {
            throw errorFromResponse(path: path, statusCode: httpResponse.statusCode, data: data)
        }

        let fileName = Self.fileName(from: httpResponse) ?? fallbackFileName
        return (data, fileName)
    }

    private static func fileName(from response: HTTPURLResponse) -> String? {
        guard let header = response.value(forHTTPHeaderField: "Content-Disposition") else {
            return nil
        }

        if let starredRange = header.range(of: "filename*=UTF-8''", options: .caseInsensitive) {
            let rest = header[starredRange.upperBound...]
            let end = rest.firstIndex(of: ";") ?? rest.endIndex
            let encoded = String(rest[..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
            return encoded.removingPercentEncoding ?? encoded
        }

        guard let range = header.range(of: "filename=", options: .caseInsensitive) else {
            return nil
        }

        var value = String(header[range.upperBound...])
        if let semicolon = value.firstIndex(of: ";") {
            value = String(value[..<semicolon])
        }

        return value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    private func send(
        path: String,
        method: String,
        queryItems: [URLQueryItem]? = nil,
        json: [String: Any]? = nil,
        multipartBody: Data? = nil,
        contentType: String? = nil,
        accept: String = "application/json"
    ) async throws -> (Data, HTTPURLResponse) {
        await APIResolver.resolveIfNeeded()

        let (cleanPath, embeddedQueryItems) = Self.splitPathAndQuery(path)
        let mergedQueryItems = Self.mergeQueryItems(embeddedQueryItems, queryItems)

        var url = APIConfig.baseURL
        url.append(path: cleanPath)

        if !mergedQueryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = mergedQueryItems
            if let composedURL = components?.url {
                url = composedURL
            }
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue(accept, forHTTPHeaderField: "Accept")

        if shouldAttachAuthorization(for: cleanPath), let token = KeychainStore.loadToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let json {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: json)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let multipartBody {
            urlRequest.httpBody = multipartBody
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        #if DEBUG
        print("[API] \(method) \(url.absoluteString)")
        #endif

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        #if DEBUG
        print("[API] \(method) \(url.path) -> \(httpResponse.statusCode)")
        #endif

        return (data, httpResponse)
    }

    private static func splitPathAndQuery(_ path: String) -> (String, [URLQueryItem]) {
        guard let questionMark = path.firstIndex(of: "?") else {
            return (path, [])
        }

        let cleanPath = String(path[..<questionMark])
        let query = String(path[path.index(after: questionMark)...])
        guard let components = URLComponents(string: "https://local.invalid?\(query)") else {
            return (cleanPath, [])
        }

        return (cleanPath, components.queryItems ?? [])
    }

    private static func mergeQueryItems(
        _ lhs: [URLQueryItem],
        _ rhs: [URLQueryItem]?
    ) -> [URLQueryItem] {
        var merged = lhs
        if let rhs {
            merged.append(contentsOf: rhs)
        }
        return merged
    }

    private func errorFromResponse(path: String, statusCode: Int, data: Data) -> APIError {
        if statusCode == 401 {
            if shouldBroadcastSessionExpired(for: path) {
                KeychainStore.deleteToken()
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
            }
            return .unauthorized
        }

        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            let detail = errorResponse.errors?.values.first?.first
            return .server(detail ?? errorResponse.message)
        }

        let body = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if statusCode == 413 || body.localizedCaseInsensitiveContains("Content-Length")
            || body.localizedCaseInsensitiveContains("post_max_size")
            || body.localizedCaseInsensitiveContains("exceeds the limit") {
            return .server("File terlalu besar untuk diunggah. Maksimal 2MB.")
        }

        if !body.isEmpty {
            let plain = body
                .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
                .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let preview = plain.count > 160 ? String(plain.prefix(160)) + "…" : plain
            return .server(preview.isEmpty ? "HTTP \(statusCode)" : preview)
        }

        return .server("HTTP \(statusCode). Pastikan backend Laravel berjalan dan route terbaru sudah aktif.")
    }

    private func shouldAttachAuthorization(for path: String) -> Bool {
        !Self.publicAuthPaths.contains(path)
    }

    private func shouldBroadcastSessionExpired(for path: String) -> Bool {
        if path == "auth/me" {
            return false
        }

        return !Self.publicAuthPaths.contains(path)
    }

    private static let publicAuthPaths: Set<String> = [
        "auth/login",
        "auth/google",
        "auth/apple",
        "auth/register",
        "auth/forgot-password",
        "auth/two-factor/verify",
    ]
}

private extension Data {
    mutating func appendFormField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append(value.data(using: .utf8)!)
        append("\r\n".data(using: .utf8)!)
    }

    mutating func appendFileField(
        name: String,
        fileName: String,
        mimeType: String,
        fileData: Data,
        boundary: String
    ) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(fileData)
        append("\r\n".data(using: .utf8)!)
    }
}
