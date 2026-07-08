import Foundation

struct APIErrorResponse: Decodable {
    let message: String
    let errors: [String: [String]]?
}

enum APIError: LocalizedError {
    case server(String)
    case unauthorized
    case decoding(String?)
    case unknown

    var errorDescription: String? {
        switch self {
        case .server(let message):
            return message
        case .unauthorized:
            return "Sesi berakhir, silakan login kembali."
        case .decoding:
            return "Gagal membaca respons server."
        case .unknown:
            return "Terjadi kesalahan tak terduga. Pastikan backend Laravel sedang berjalan."
        }
    }
}

extension Error {
    var isRequestCancelled: Bool {
        if self is CancellationError {
            return true
        }

        if let urlError = self as? URLError, urlError.code == .cancelled {
            return true
        }

        return false
    }

    var userFacingMessage: String {
        if let localized = self as? LocalizedError, let message = localized.errorDescription {
            return message
        }

        if let urlError = self as? URLError {
            switch urlError.code {
            case .cancelled:
                return ""
            case .notConnectedToInternet, .networkConnectionLost:
                return "Tidak ada koneksi internet. Periksa Wi-Fi perangkat Anda."
            case .cannotConnectToHost, .cannotFindHost, .timedOut:
                return "Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi."
            default:
                return "Gagal menghubungi server (\(urlError.localizedDescription))."
            }
        }

        if self is CancellationError {
            return ""
        }

        return "Gagal memuat data."
    }
}
