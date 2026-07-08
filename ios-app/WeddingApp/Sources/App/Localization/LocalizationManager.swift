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
        if code == AppLanguage.indonesian.rawValue {
            bundle = .main
            return
        }

        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            bundle = languageBundle
        } else {
            bundle = .main
        }
    }

    func string(for key: String) -> String {
        let value = bundle.localizedString(forKey: key, value: nil, table: nil)
        if value != key {
            return value
        }

        if languageCode != AppLanguage.indonesian.rawValue,
           let path = Bundle.main.path(forResource: AppLanguage.indonesian.rawValue, ofType: "lproj"),
           let fallbackBundle = Bundle(path: path) {
            let fallback = fallbackBundle.localizedString(forKey: key, value: key, table: nil)
            return fallback == key ? key : fallback
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
