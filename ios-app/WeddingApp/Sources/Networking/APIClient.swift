import Foundation

final class APIClient {
    static let shared = APIClient()

    private let session = URLSession.shared

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

    private init() {}

    func request<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        json: [String: Any]? = nil
    ) async throws -> Response {
        let (data, httpResponse) = try await send(path: path, method: method, queryItems: queryItems, json: json)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw errorFromResponse(statusCode: httpResponse.statusCode, data: data)
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
            throw errorFromResponse(statusCode: httpResponse.statusCode, data: data)
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
            throw errorFromResponse(statusCode: httpResponse.statusCode, data: data)
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

    private func send(
        path: String,
        method: String,
        queryItems: [URLQueryItem]? = nil,
        json: [String: Any]? = nil,
        multipartBody: Data? = nil,
        contentType: String? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        var url = APIConfig.baseURL
        url.append(path: path)

        if let queryItems, !queryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            if let composedURL = components?.url {
                url = composedURL
            }
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = KeychainStore.loadToken() {
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

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        return (data, httpResponse)
    }

    private func errorFromResponse(statusCode: Int, data: Data) -> APIError {
        if statusCode == 401 {
            KeychainStore.deleteToken()
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
            return .unauthorized
        }

        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            let detail = errorResponse.errors?.values.first?.first
            return .server(detail ?? errorResponse.message)
        }

        return .unknown
    }
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
