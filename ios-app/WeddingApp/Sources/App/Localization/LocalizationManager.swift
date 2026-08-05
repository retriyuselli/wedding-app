import Foundation

final class LocalizationManager {
    static let shared = LocalizationManager()

    private var bundle: Bundle = .main
    private var languageCode: String = AppLanguage.indonesian.rawValue

    private init() {
        if let raw = UserDefaults.standard.string(forKey: "app_language"),
           AppLanguage(rawValue: raw) != nil {
            languageCode = raw
        }
        applyLanguage(code: languageCode)
    }

    func setLanguage(_ language: AppLanguage) {
        languageCode = language.rawValue
        applyLanguage(code: language.rawValue)
    }

    private func applyLanguage(code: String) {
        // Always resolve an explicit .lproj bundle.
        // Using Bundle.main for Indonesian incorrectly follows the device/app
        // development language (often English), so ID strings never appear.
        if let languageBundle = lprojBundle(for: code) {
            bundle = languageBundle
            return
        }

        if code != AppLanguage.indonesian.rawValue,
           let indonesianBundle = lprojBundle(for: AppLanguage.indonesian.rawValue) {
            bundle = indonesianBundle
            return
        }

        bundle = .main
    }

    private func lprojBundle(for code: String) -> Bundle? {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }

    func string(for key: String) -> String {
        let value = bundle.localizedString(forKey: key, value: nil, table: nil)
        if value != key {
            return value
        }

        // Fallback to the other language pack, then the key itself.
        let fallbackCode = languageCode == AppLanguage.indonesian.rawValue
            ? AppLanguage.english.rawValue
            : AppLanguage.indonesian.rawValue

        if let fallbackBundle = lprojBundle(for: fallbackCode) {
            let fallback = fallbackBundle.localizedString(forKey: key, value: key, table: nil)
            if fallback != key {
                return fallback
            }
        }

        return key
    }

    func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: string(for: key), locale: locale, arguments: arguments)
    }

    var locale: Locale {
        Locale(identifier: languageCode == AppLanguage.indonesian.rawValue ? "id_ID" : "en_US")
    }

    var isEnglish: Bool {
        languageCode == AppLanguage.english.rawValue
    }
}

extension String {
    var localized: String {
        LocalizationManager.shared.string(for: self)
    }

    func localized(_ arguments: CVarArg...) -> String {
        LocalizationManager.shared.format(self, arguments)
    }
}
