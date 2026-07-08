import Foundation

/// Feature flag bahasa — nonisolated agar bisa diakses dari enum dan view tanpa MainActor.
enum LanguageFeature {
    /// Ubah ke `true` saat fitur Bahasa siap dirilis ke user.
    static let isSelectionEnabled = false
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case indonesian = "id"
    case english = "en"

    var id: String { rawValue }

    /// Nama bahasa tetap statis agar tidak ikut berubah saat ganti bahasa.
    var label: String {
        switch self {
        case .indonesian: return "Bahasa Indonesia"
        case .english: return "English"
        }
    }

    var nativeSubtitle: String {
        switch self {
        case .indonesian: return "Indonesia"
        case .english: return "Inggris"
        }
    }

    var flag: String {
        switch self {
        case .indonesian: return "🇮🇩"
        case .english: return "🇬🇧"
        }
    }

    var isAvailable: Bool {
        switch self {
        case .indonesian: return true
        case .english: return LanguageFeature.isSelectionEnabled
        }
    }
}

@MainActor
final class LanguageStore: ObservableObject {
    static let shared = LanguageStore()

    @Published private(set) var selected: AppLanguage

    private let storageKey = "app_language"

    private init() {
        if LanguageFeature.isSelectionEnabled,
           let raw = UserDefaults.standard.string(forKey: storageKey),
           let language = AppLanguage(rawValue: raw) {
            selected = language
        } else {
            selected = .indonesian
        }

        LocalizationManager.shared.setLanguage(selected)
    }

    func select(_ language: AppLanguage) {
        guard LanguageFeature.isSelectionEnabled else { return }
        guard language.isAvailable, selected != language else { return }

        selected = language
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        LocalizationManager.shared.setLanguage(language)
    }
}
