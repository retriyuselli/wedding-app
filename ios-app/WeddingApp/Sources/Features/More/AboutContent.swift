import Foundation

enum AboutContent {
    static let developerName = "Makna Kreatif Indonesia"
    static let website = "www.weddingapp.co.id"
    static let websiteURL = URL(string: "https://www.weddingapp.co.id")!
    /// Public link for "Share Wedding App". Prefer App Store URL after release.
    static var shareURL: URL { appStoreURL ?? websiteURL }
    static let email = "info@weddingapp.co.id"
    static let privacyPolicyURL = URL(string: "https://www.weddingapp.co.id/privacy-policy")!
    static let termsURL = URL(string: "https://www.weddingapp.co.id/terms")!

    /// Numeric App Store ID from App Store Connect (e.g. "1234567890").
    /// Leave `nil` while the build is still on TestFlight / awaiting review.
    static let appStoreID: String? = nil

    /// App product page. Filled automatically once `appStoreID` is set.
    static var appStoreURL: URL? {
        guard let appStoreID, !appStoreID.isEmpty else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }

    /// Deep link that opens the App Store "Write a Review" screen.
    static var appStoreWriteReviewURL: URL? {
        guard let appStoreID, !appStoreID.isEmpty else { return nil }
        return URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreID)?action=write-review")
    }

    static var isAppStoreReviewAvailable: Bool {
        appStoreWriteReviewURL != nil
    }
    static var copyrightYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    static let heroDescription =
        "Aplikasi pendamping untuk membantu Anda merencanakan pernikahan dengan lebih mudah, terorganisir, dan berkesan."

    static let highlights: [AboutHighlight] = [
        AboutHighlight(
            icon: "heart.fill",
            title: "Misi Kami",
            description: "Membantu setiap pasangan mempersiapkan hari bahagia mereka dengan lebih mudah dan menyenangkan."
        ),
        AboutHighlight(
            icon: "scope",
            title: "Tujuan Kami",
            description: "Menjadi aplikasi pernikahan terdepan yang memberikan pengalaman terbaik bagi calon pengantin di Indonesia."
        ),
        AboutHighlight(
            icon: "star.fill",
            title: "Apa yang Bisa Anda Lakukan",
            description: "Kelola checklist, tamu, anggaran, dokumen penting, temukan inspirasi, serta berkomunikasi dengan vendor dalam satu aplikasi."
        ),
        AboutHighlight(
            icon: "person.2.fill",
            title: "Untuk Siapa Aplikasi Ini",
            description: "Dirancang khusus untuk pasangan yang sedang mempersiapkan pernikahan agar lebih terorganisir dan tidak ada yang terlewat."
        ),
    ]

    static let socialLinks: [AboutSocialLink] = [
        AboutSocialLink(
            name: "Instagram",
            brand: .instagram,
            url: URL(string: "https://www.instagram.com/makna.wedding?igsh=Y2Y2enlwNmsyMjNt")!
        ),
        AboutSocialLink(
            name: "TikTok",
            brand: .tiktok,
            url: URL(string: "https://www.tiktok.com/@makna.wedding?_r=1&_t=ZS-97rDQtUeA4n")!
        ),
        AboutSocialLink(
            name: "YouTube",
            brand: .youtube,
            url: URL(string: "https://youtube.com/@maknawedding?si=b52NVwW4-NOHddJI")!
        ),
    ]
}

enum AboutSocialBrand {
    case instagram
    case tiktok
    case youtube
}

struct AboutHighlight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct AboutSocialLink: Identifiable {
    let id = UUID()
    let name: String
    let brand: AboutSocialBrand
    let url: URL
}
