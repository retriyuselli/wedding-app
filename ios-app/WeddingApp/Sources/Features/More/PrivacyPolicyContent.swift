import Foundation

struct PrivacyPolicySection: Identifiable {
    let id = UUID()
    let title: String
    let paragraphs: [String]
    let bullets: [String]
}

enum PrivacyPolicyLanguage: String, CaseIterable, Identifiable {
    case indonesian = "id"
    case english = "en"

    var id: String { rawValue }

    var chipLabel: String {
        switch self {
        case .indonesian: return "Indonesia"
        case .english: return "English"
        }
    }
}

struct PrivacyPolicyLocaleContent {
    let pageTitle: String
    let lastUpdated: String
    let introTitle: String
    let introduction: String
    let sections: [PrivacyPolicySection]
    let contactTitle: String
    let contactDescription: String
    let emailButton: String
    let helpButton: String
    let webVersionLabel: String
}

enum PrivacyPolicyContent {
    static let contactEmail = AboutContent.email

    static func content(for language: PrivacyPolicyLanguage) -> PrivacyPolicyLocaleContent {
        switch language {
        case .indonesian: return indonesian
        case .english: return english
        }
    }

    private static let indonesian = PrivacyPolicyLocaleContent(
        pageTitle: "Kebijakan Privasi",
        lastUpdated: "Terakhir diperbarui 8 Juli 2026",
        introTitle: "Komitmen Privasi Wedding App",
        introduction: """
        Kebijakan Privasi ini menjelaskan bagaimana Wedding App ("kami") mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Anda saat menggunakan aplikasi mobile Wedding App dan layanan terkait.
        """,
        sections: [
            PrivacyPolicySection(
                title: "1. Data yang Kami Kumpulkan",
                paragraphs: ["Kami dapat mengumpulkan data berikut saat Anda menggunakan Wedding App:"],
                bullets: [
                    "Data akun: nama, alamat email, kata sandi (terenkripsi), foto profil, nomor WhatsApp, serta informasi autentikasi dari Google atau Apple jika Anda masuk dengan metode tersebut.",
                    "Data pernikahan: nama pasangan, tanggal dan detail acara, lokasi, budaya/adat, daftar tamu, anggaran, dokumen, checklist persiapan, dan informasi vendor yang Anda simpan.",
                    "Data komunikasi: pesan support, topik pertanyaan, serta riwayat percakapan dengan tim Wedding App.",
                    "Data perangkat: token push notification, nama perangkat, informasi sesi login, dan log teknis untuk keamanan aplikasi.",
                    "Data penggunaan: preferensi notifikasi, interaksi fitur, serta data yang Anda unggah secara sukarela ke aplikasi.",
                ]
            ),
            PrivacyPolicySection(
                title: "2. Cara Kami Menggunakan Data",
                paragraphs: ["Data pribadi Anda digunakan untuk tujuan berikut:"],
                bullets: [
                    "Menyediakan, mengoperasikan, dan meningkatkan fitur perencanaan pernikahan di aplikasi.",
                    "Mengelola akun Anda, autentikasi, dan keamanan sesi.",
                    "Mengirim notifikasi terkait aktivitas akun, balasan support, dan pengingat pernikahan sesuai pengaturan Anda.",
                    "Memberikan dukungan pelanggan dan menanggapi pertanyaan atau permintaan Anda.",
                    "Menganalisis penggunaan aplikasi secara agregat untuk meningkatkan pengalaman pengguna.",
                    "Memenuhi kewajiban hukum dan mencegah penyalahgunaan layanan.",
                ]
            ),
            PrivacyPolicySection(
                title: "3. Dasar Pemrosesan Data",
                paragraphs: ["Kami memproses data pribadi Anda berdasarkan:"],
                bullets: [
                    "Persetujuan Anda saat mendaftar dan menggunakan fitur tertentu.",
                    "Pelaksanaan perjanjian layanan antara Anda dan Wedding App.",
                    "Kepentingan sah kami untuk menjaga keamanan, mencegah penipuan, dan meningkatkan layanan.",
                    "Kewajiban hukum yang berlaku di Indonesia.",
                ]
            ),
            PrivacyPolicySection(
                title: "4. Berbagi Data dengan Pihak Ketiga",
                paragraphs: ["Kami tidak menjual data pribadi Anda. Data hanya dapat dibagikan dalam kondisi berikut:"],
                bullets: [
                    "Penyedia layanan teknis yang membantu operasional aplikasi (misalnya hosting, autentikasi, push notification), dengan kewajiban kerahasiaan.",
                    "Vendor atau pihak ketiga hanya jika Anda secara eksplisit berinteraksi melalui fitur aplikasi.",
                    "Otoritas hukum apabila diwajibkan oleh peraturan perundang-undangan yang berlaku.",
                    "Proses bisnis seperti merger atau akuisisi, dengan pemberitahuan kepada pengguna jika diperlukan.",
                ]
            ),
            PrivacyPolicySection(
                title: "5. Penyimpanan dan Keamanan Data",
                paragraphs: [
                    "Kami menerapkan langkah keamanan teknis dan organisasi yang wajar untuk melindungi data Anda dari akses, perubahan, pengungkapan, atau penghancuran yang tidak sah.",
                    "Data disimpan selama akun Anda aktif atau selama diperlukan untuk menyediakan layanan dan memenuhi kewajiban hukum. Anda dapat meminta penghapusan akun melalui menu Privasi & Keamanan.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "6. Hak Anda sebagai Pengguna",
                paragraphs: ["Sesuai peraturan yang berlaku, Anda berhak untuk:"],
                bullets: [
                    "Mengakses dan memperbarui data profil serta detail pernikahan melalui aplikasi.",
                    "Menarik persetujuan notifikasi push melalui pengaturan perangkat atau aplikasi.",
                    "Meminta salinan data pribadi Anda (fitur unduh data).",
                    "Menghapus akun dan data terkait melalui menu Hapus Akun.",
                    "Menghubungi kami untuk pertanyaan atau keberatan terkait pemrosesan data pribadi.",
                ]
            ),
            PrivacyPolicySection(
                title: "7. Cookie, Token, dan Teknologi Serupa",
                paragraphs: [
                    "Aplikasi mobile dapat menyimpan token autentikasi secara aman di perangkat Anda serta token push notification untuk mengirim pemberitahuan. Anda dapat menghapus token tersebut dengan logout atau mencabut izin notifikasi di pengaturan perangkat.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "8. Privasi Anak",
                paragraphs: [
                    "Wedding App tidak ditujukan untuk anak di bawah 17 tahun tanpa pengawasan orang tua atau wali. Kami tidak dengan sengaja mengumpulkan data pribadi dari anak tanpa persetujuan yang sah.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "9. Perubahan Kebijakan Privasi",
                paragraphs: [
                    "Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan material akan diberitahukan melalui aplikasi atau email. Tanggal pembaruan terakhir tercantum di bagian atas halaman ini.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "10. Hubungi Kami",
                paragraphs: [
                    "Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini atau ingin menggunakan hak privasi Anda, silakan hubungi:",
                    "PT Makna Kreatif Indonesia\nEmail: \(contactEmail)\nWebsite: \(AboutContent.website)",
                ],
                bullets: []
            ),
        ],
        contactTitle: "Butuh bantuan terkait privasi?",
        contactDescription: "Tim kami siap membantu pertanyaan seputar data pribadi dan hak privasi Anda.",
        emailButton: "Email Kami",
        helpButton: "Bantuan",
        webVersionLabel: "Buka versi web di \(AboutContent.website)"
    )

    private static let english = PrivacyPolicyLocaleContent(
        pageTitle: "Privacy Policy",
        lastUpdated: "Last updated July 8, 2026",
        introTitle: "Wedding App Privacy Commitment",
        introduction: """
        This Privacy Policy explains how Wedding App ("we") collects, uses, stores, and protects your personal data when you use the Wedding App mobile application and related services.
        """,
        sections: [
            PrivacyPolicySection(
                title: "1. Data We Collect",
                paragraphs: ["We may collect the following data when you use Wedding App:"],
                bullets: [
                    "Account data: name, email address, password (encrypted), profile photo, WhatsApp number, and authentication information from Google or Apple if you sign in with those methods.",
                    "Wedding data: couple names, event dates and details, location, culture/traditions, guest lists, budgets, documents, preparation checklists, and vendor information you save.",
                    "Communication data: support messages, question topics, and conversation history with the Wedding App support team.",
                    "Device data: push notification tokens, device name, login session information, and technical logs for app security.",
                    "Usage data: notification preferences, feature interactions, and data you voluntarily upload to the app.",
                ]
            ),
            PrivacyPolicySection(
                title: "2. How We Use Data",
                paragraphs: ["Your personal data is used for the following purposes:"],
                bullets: [
                    "Providing, operating, and improving wedding planning features in the app.",
                    "Managing your account, authentication, and session security.",
                    "Sending notifications related to account activity, support replies, and wedding reminders according to your settings.",
                    "Providing customer support and responding to your questions or requests.",
                    "Analyzing app usage in aggregate to improve the user experience.",
                    "Fulfilling legal obligations and preventing misuse of the service.",
                ]
            ),
            PrivacyPolicySection(
                title: "3. Legal Basis for Processing",
                paragraphs: ["We process your personal data based on:"],
                bullets: [
                    "Your consent when registering and using certain features.",
                    "Performance of the service agreement between you and Wedding App.",
                    "Our legitimate interests in maintaining security, preventing fraud, and improving services.",
                    "Legal obligations applicable in Indonesia.",
                ]
            ),
            PrivacyPolicySection(
                title: "4. Sharing Data with Third Parties",
                paragraphs: ["We do not sell your personal data. Data may only be shared under the following conditions:"],
                bullets: [
                    "Technical service providers that help operate the app (e.g. hosting, authentication, push notifications), subject to confidentiality obligations.",
                    "Vendors or third parties only when you explicitly interact through app features.",
                    "Legal authorities when required by applicable laws and regulations.",
                    "Business processes such as mergers or acquisitions, with notice to users when required.",
                ]
            ),
            PrivacyPolicySection(
                title: "5. Data Storage and Security",
                paragraphs: [
                    "We implement reasonable technical and organizational security measures to protect your data from unauthorized access, alteration, disclosure, or destruction.",
                    "Data is stored while your account is active or as long as needed to provide services and meet legal obligations. You may request account deletion through the Privacy & Security menu.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "6. Your Rights as a User",
                paragraphs: ["Under applicable regulations, you have the right to:"],
                bullets: [
                    "Access and update your profile and wedding details through the app.",
                    "Withdraw push notification consent through device or app settings.",
                    "Request a copy of your personal data (download data feature).",
                    "Delete your account and related data through the Delete Account menu.",
                    "Contact us with questions or objections regarding personal data processing.",
                ]
            ),
            PrivacyPolicySection(
                title: "7. Cookies, Tokens, and Similar Technologies",
                paragraphs: [
                    "The mobile app may securely store authentication tokens on your device and push notification tokens to send alerts. You can remove these tokens by logging out or revoking notification permission in your device settings.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "8. Children's Privacy",
                paragraphs: [
                    "Wedding App is not intended for children under 17 without parental or guardian supervision. We do not knowingly collect personal data from children without valid consent.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "9. Changes to This Privacy Policy",
                paragraphs: [
                    "We may update this Privacy Policy from time to time. Material changes will be notified through the app or by email. The latest update date is shown at the top of this page.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "10. Contact Us",
                paragraphs: [
                    "If you have questions about this Privacy Policy or wish to exercise your privacy rights, please contact:",
                    "PT Makna Kreatif Indonesia\nEmail: \(contactEmail)\nWebsite: \(AboutContent.website)",
                ],
                bullets: []
            ),
        ],
        contactTitle: "Need help with privacy?",
        contactDescription: "Our team is ready to assist with questions about your personal data and privacy rights.",
        emailButton: "Email Us",
        helpButton: "Help",
        webVersionLabel: "Open web version at \(AboutContent.website)"
    )
}
