import Foundation
import UIKit

enum GuestContactLinker {
    static func digits(from phone: String) -> String {
        phone.filter(\.isNumber)
    }

    static func telURL(phone: String) -> URL? {
        let digits = digits(from: phone)
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel:\(digits)")
    }

    static func mailtoURL(email: String) -> URL? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: "mailto:\(trimmed)")
    }

    /// Normalizes local Indonesian numbers (08…) to international digits for wa.me.
    static func whatsAppURL(phone: String) -> URL? {
        var digits = digits(from: phone)
        guard !digits.isEmpty else { return nil }

        if digits.hasPrefix("0") {
            digits = "62" + digits.dropFirst()
        }

        return URL(string: "https://wa.me/\(digits)")
    }

    static func open(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
