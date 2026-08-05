import Foundation

struct TermsOfServiceLocaleContent {
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

enum TermsOfServiceContent {
    static let contactEmail = AboutContent.email

    static func content(for language: PrivacyPolicyLanguage) -> TermsOfServiceLocaleContent {
        switch language {
        case .indonesian: return indonesian
        case .english: return english
        }
    }

    private static let indonesian = TermsOfServiceLocaleContent(
        pageTitle: "Syarat & Ketentuan",
        lastUpdated: "Terakhir diperbarui 8 Juli 2026",
        introTitle: "Ketentuan Penggunaan Wedding App",
        introduction: """
        Syarat & Ketentuan ini mengatur penggunaan Anda atas aplikasi mobile Wedding App dan layanan terkait yang disediakan oleh PT Makna Kreatif Indonesia ("kami"). Dengan mendaftar, mengakses, atau menggunakan Wedding App, Anda dianggap telah membaca, memahami, dan menyetujui seluruh ketentuan berikut.
        """,
        sections: [
            PrivacyPolicySection(
                title: "1. Penerimaan Syarat",
                paragraphs: [
                    "Dengan menggunakan Wedding App, Anda menyetujui Syarat & Ketentuan ini serta Kebijakan Privasi kami. Jika Anda tidak setuju, mohon tidak menggunakan layanan ini.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "2. Definisi",
                paragraphs: ["Dalam dokumen ini:"],
                bullets: [
                    "\"Aplikasi\" berarti aplikasi mobile Wedding App dan fitur-fitur di dalamnya.",
                    "\"Pengguna\" berarti individu yang mendaftar dan menggunakan Aplikasi.",
                    "\"Layanan\" berarti seluruh fitur perencanaan pernikahan yang disediakan melalui Aplikasi.",
                    "\"Konten Pengguna\" berarti data, teks, foto, dokumen, dan informasi lain yang Anda unggah atau simpan di Aplikasi.",
                ]
            ),
            PrivacyPolicySection(
                title: "3. Akun dan Kelayakan",
                paragraphs: [
                    "Untuk menggunakan fitur tertentu, Anda harus membuat akun dengan informasi yang akurat dan terkini. Anda bertanggung jawab menjaga kerahasiaan kredensial akun dan seluruh aktivitas yang terjadi melalui akun Anda.",
                ],
                bullets: [
                    "Anda harus berusia minimal 17 tahun atau menggunakan Aplikasi di bawah pengawasan orang tua/wali yang sah.",
                    "Satu akun hanya boleh digunakan oleh pengguna yang berwenang dan tidak boleh dibagikan kepada pihak lain tanpa izin.",
                    "Kami berhak menangguhkan atau menutup akun yang melanggar Syarat & Ketentuan ini.",
                ]
            ),
            PrivacyPolicySection(
                title: "4. Penggunaan Layanan",
                paragraphs: [
                    "Wedding App menyediakan alat bantu perencanaan pernikahan, termasuk namun tidak terbatas pada checklist, manajemen tamu, anggaran, dokumen, inspirasi, dan komunikasi support.",
                ],
                bullets: [
                    "Layanan disediakan untuk keperluan pribadi dan non-komersial dalam konteks perencanaan pernikahan.",
                    "Kami dapat menambah, mengubah, atau menghentikan fitur tertentu untuk meningkatkan layanan atau keamanan.",
                    "Ketersediaan layanan dapat terpengaruh oleh pemeliharaan sistem, gangguan jaringan, atau faktor di luar kendali kami.",
                ]
            ),
            PrivacyPolicySection(
                title: "5. Konten Pengguna",
                paragraphs: [
                    "Anda tetap memiliki hak atas Konten Pengguna yang Anda unggah. Dengan menggunakan Aplikasi, Anda memberikan lisensi terbatas kepada kami untuk menyimpan, memproses, dan menampilkan konten tersebut semata-mata untuk menyediakan Layanan.",
                ],
                bullets: [
                    "Anda menjamin bahwa konten yang diunggah tidak melanggar hukum, hak pihak ketiga, atau norma yang berlaku.",
                    "Anda bertanggung jawab atas keakuratan data pernikahan, tamu, anggaran, dan informasi lain yang Anda masukkan.",
                    "Kami dapat menghapus konten yang melanggar hukum atau Syarat & Ketentuan ini.",
                ]
            ),
            PrivacyPolicySection(
                title: "6. Vendor dan Layanan Pihak Ketiga",
                paragraphs: [
                    "Aplikasi dapat menampilkan informasi vendor atau menghubungkan Anda ke layanan pihak ketiga. Kami tidak bertanggung jawab atas kualitas, harga, ketersediaan, atau kinerja layanan pihak ketiga tersebut.",
                ],
                bullets: [
                    "Transaksi atau kesepakatan dengan vendor dilakukan di luar tanggung jawab langsung Wedding App, kecuali dinyatakan lain secara tertulis.",
                    "Autentikasi melalui Google atau Apple tunduk pada ketentuan masing-masing penyedia layanan.",
                ]
            ),
            PrivacyPolicySection(
                title: "7. Hak Kekayaan Intelektual",
                paragraphs: [
                    "Seluruh merek dagang, logo, desain antarmuka, kode, dan materi lain dalam Aplikasi (selain Konten Pengguna) adalah milik kami atau pemberi lisensi kami dan dilindungi oleh hukum yang berlaku.",
                ],
                bullets: [
                    "Anda tidak diperkenankan menyalin, memodifikasi, mendistribusikan, atau melakukan reverse engineering atas Aplikasi tanpa izin tertulis.",
                ]
            ),
            PrivacyPolicySection(
                title: "8. Larangan Penggunaan",
                paragraphs: ["Anda dilarang menggunakan Aplikasi untuk:"],
                bullets: [
                    "Aktivitas ilegal, penipuan, pelecehan, atau pelanggaran hak pihak lain.",
                    "Mengunggah malware, spam, atau konten yang mengandung kebencian, pornografi, atau kekerasan.",
                    "Mencoba mengakses sistem, akun, atau data pengguna lain tanpa izin.",
                    "Mengganggu stabilitas atau keamanan server dan infrastruktur kami.",
                ]
            ),
            PrivacyPolicySection(
                title: "9. Penafian dan Batasan Tanggung Jawab",
                paragraphs: [
                    "Aplikasi disediakan \"sebagaimana adanya\". Kami berupaya menjaga akurasi dan ketersediaan layanan, namun tidak menjamin bahwa Aplikasi bebas dari kesalahan atau gangguan.",
                    "Sejauh diizinkan oleh hukum, kami tidak bertanggung jawab atas kerugian tidak langsung, kehilangan data akibat kelalaian pengguna, atau keputusan pernikahan yang diambil berdasarkan informasi di Aplikasi.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "10. Penghentian Layanan",
                paragraphs: [
                    "Anda dapat berhenti menggunakan Aplikasi kapan saja dan menghapus akun melalui menu Privasi & Keamanan. Kami dapat menangguhkan atau menghentikan akses Anda jika terjadi pelanggaran terhadap Syarat & Ketentuan ini atau untuk kepatuhan hukum.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "11. Perubahan Syarat & Ketentuan",
                paragraphs: [
                    "Kami dapat memperbarui Syarat & Ketentuan ini dari waktu ke waktu. Perubahan material akan diberitahukan melalui Aplikasi atau email. Penggunaan berkelanjutan setelah pembaruan dianggap sebagai persetujuan Anda.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "12. Hukum yang Berlaku",
                paragraphs: [
                    "Syarat & Ketentuan ini diatur oleh dan ditafirkan sesuai hukum Republik Indonesia. Sengketa yang timbul akan diselesaikan melalui musyawarah terlebih dahulu, dan apabila diperlukan melalui pengadilan yang berwenang di Indonesia.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "13. Hubungi Kami",
                paragraphs: [
                    "Jika Anda memiliki pertanyaan tentang Syarat & Ketentuan ini, silakan hubungi:",
                    "PT Makna Kreatif Indonesia\nEmail: \(contactEmail)\nWebsite: \(AboutContent.website)",
                ],
                bullets: []
            ),
        ],
        contactTitle: "Butuh bantuan terkait syarat layanan?",
        contactDescription: "Tim kami siap membantu pertanyaan seputar penggunaan aplikasi dan ketentuan layanan.",
        emailButton: "Email Kami",
        helpButton: "Bantuan",
        webVersionLabel: "Buka versi web di \(AboutContent.website)"
    )

    private static let english = TermsOfServiceLocaleContent(
        pageTitle: "Terms & Conditions",
        lastUpdated: "Last updated July 8, 2026",
        introTitle: "Wedding App Terms of Use",
        introduction: """
        These Terms & Conditions govern your use of the Wedding App mobile application and related services provided by PT Makna Kreatif Indonesia ("we"). By registering, accessing, or using Wedding App, you are deemed to have read, understood, and agreed to all of the following terms.
        """,
        sections: [
            PrivacyPolicySection(
                title: "1. Acceptance of Terms",
                paragraphs: [
                    "By using Wedding App, you agree to these Terms & Conditions and our Privacy Policy. If you do not agree, please do not use the service.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "2. Definitions",
                paragraphs: ["In this document:"],
                bullets: [
                    "\"Application\" means the Wedding App mobile application and its features.",
                    "\"User\" means an individual who registers for and uses the Application.",
                    "\"Service\" means all wedding planning features provided through the Application.",
                    "\"User Content\" means data, text, photos, documents, and other information you upload or store in the Application.",
                ]
            ),
            PrivacyPolicySection(
                title: "3. Account and Eligibility",
                paragraphs: [
                    "To use certain features, you must create an account with accurate and up-to-date information. You are responsible for keeping your account credentials confidential and for all activity under your account.",
                ],
                bullets: [
                    "You must be at least 17 years old or use the Application under valid parental or guardian supervision.",
                    "One account may only be used by the authorized user and must not be shared with others without permission.",
                    "We may suspend or close accounts that violate these Terms & Conditions.",
                ]
            ),
            PrivacyPolicySection(
                title: "4. Use of Service",
                paragraphs: [
                    "Wedding App provides wedding planning tools including, but not limited to, checklists, guest management, budgets, documents, inspiration, and support communication.",
                ],
                bullets: [
                    "The Service is provided for personal, non-commercial use in the context of wedding planning.",
                    "We may add, modify, or discontinue certain features to improve the service or security.",
                    "Service availability may be affected by system maintenance, network disruptions, or factors beyond our control.",
                ]
            ),
            PrivacyPolicySection(
                title: "5. User Content",
                paragraphs: [
                    "You retain ownership of User Content you upload. By using the Application, you grant us a limited license to store, process, and display that content solely to provide the Service.",
                ],
                bullets: [
                    "You warrant that uploaded content does not violate laws, third-party rights, or applicable norms.",
                    "You are responsible for the accuracy of wedding details, guests, budgets, and other information you enter.",
                    "We may remove content that violates laws or these Terms & Conditions.",
                ]
            ),
            PrivacyPolicySection(
                title: "6. Vendors and Third-Party Services",
                paragraphs: [
                    "The Application may display vendor information or connect you to third-party services. We are not responsible for the quality, pricing, availability, or performance of those third-party services.",
                ],
                bullets: [
                    "Transactions or agreements with vendors are outside Wedding App's direct responsibility unless otherwise stated in writing.",
                    "Authentication through Google or Apple is subject to each provider's terms.",
                ]
            ),
            PrivacyPolicySection(
                title: "7. Intellectual Property",
                paragraphs: [
                    "All trademarks, logos, interface designs, code, and other materials in the Application (other than User Content) are owned by us or our licensors and protected by applicable law.",
                ],
                bullets: [
                    "You may not copy, modify, distribute, or reverse engineer the Application without written permission.",
                ]
            ),
            PrivacyPolicySection(
                title: "8. Prohibited Conduct",
                paragraphs: ["You may not use the Application for:"],
                bullets: [
                    "Illegal activity, fraud, harassment, or infringement of others' rights.",
                    "Uploading malware, spam, or content containing hate, pornography, or violence.",
                    "Attempting to access systems, accounts, or other users' data without authorization.",
                    "Disrupting the stability or security of our servers and infrastructure.",
                ]
            ),
            PrivacyPolicySection(
                title: "9. Disclaimer and Limitation of Liability",
                paragraphs: [
                    "The Application is provided \"as is\". We strive to maintain accuracy and availability but do not guarantee the Application is error-free or uninterrupted.",
                    "To the extent permitted by law, we are not liable for indirect losses, data loss due to user negligence, or wedding decisions made based on information in the Application.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "10. Termination",
                paragraphs: [
                    "You may stop using the Application at any time and delete your account through the Privacy & Security menu. We may suspend or terminate your access if you violate these Terms & Conditions or for legal compliance.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "11. Changes to Terms & Conditions",
                paragraphs: [
                    "We may update these Terms & Conditions from time to time. Material changes will be notified through the Application or by email. Continued use after an update constitutes your acceptance.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "12. Governing Law",
                paragraphs: [
                    "These Terms & Conditions are governed by and construed in accordance with the laws of the Republic of Indonesia. Disputes shall first be resolved through deliberation and, if necessary, through competent courts in Indonesia.",
                ],
                bullets: []
            ),
            PrivacyPolicySection(
                title: "13. Contact Us",
                paragraphs: [
                    "If you have questions about these Terms & Conditions, please contact:",
                    "PT Makna Kreatif Indonesia\nEmail: \(contactEmail)\nWebsite: \(AboutContent.website)",
                ],
                bullets: []
            ),
        ],
        contactTitle: "Need help with terms of service?",
        contactDescription: "Our team is ready to assist with questions about app usage and service terms.",
        emailButton: "Email Us",
        helpButton: "Help",
        webVersionLabel: "Open web version at \(AboutContent.website)"
    )
}
