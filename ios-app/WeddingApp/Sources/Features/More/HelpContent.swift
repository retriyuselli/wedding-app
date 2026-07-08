import Foundation

enum HelpTopicKind: String, CaseIterable, Identifiable {
    case gettingStarted
    case preparation
    case budget
    case guests
    case security

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gettingStarted: return "book"
        case .preparation: return "checklist"
        case .budget: return "creditcard"
        case .guests: return "person.2"
        case .security: return "lock"
        }
    }

    var title: String {
        switch self {
        case .gettingStarted: return "Mulai Menggunakan"
        case .preparation: return "Persiapan Pernikahan"
        case .budget: return "Pembayaran & Budget"
        case .guests: return "Tamu & Undangan"
        case .security: return "Akun & Keamanan"
        }
    }

    var subtitle: String {
        switch self {
        case .gettingStarted: return "Panduan memulai perencanaan di aplikasi"
        case .preparation: return "Checklist dan timeline persiapan pernikahan"
        case .budget: return "Kelola anggaran dan pembayaran vendor"
        case .guests: return "Daftar tamu, RSVP, dan undangan"
        case .security: return "Privasi, keamanan, dan pengaturan akun"
        }
    }

    var articleCount: Int {
        HelpContent.articles(for: self).count
    }
}

struct HelpArticle: Identifiable, Hashable {
    let id: String
    let topic: HelpTopicKind
    let title: String
    let summary: String
    let body: String
    let readMinutes: Int
}

enum HelpContent {
    static let supportEmail = "support@weddingapp.co.id"
    static let serviceDays = "Senin - Jumat"
    static let serviceHours = "09.00 - 17.00 WIB"

    static func articles(for topic: HelpTopicKind) -> [HelpArticle] {
        allArticles.filter { $0.topic == topic }
    }

    static func article(id: String) -> HelpArticle? {
        allArticles.first { $0.id == id }
    }

    static let allArticles: [HelpArticle] = gettingStartedArticles
        + preparationArticles
        + budgetArticles
        + guestsArticles
        + securityArticles

    private static let gettingStartedArticles: [HelpArticle] = [
        HelpArticle(
            id: "gs-1",
            topic: .gettingStarted,
            title: "Membuat akun Wedding App",
            summary: "Daftar akun baru dan mulai merencanakan pernikahan Anda.",
            body: """
            Untuk membuat akun, buka aplikasi Wedding App lalu pilih Daftar. Isi nama lengkap, email, dan kata sandi Anda.

            Anda juga dapat mendaftar lebih cepat menggunakan akun Google atau Apple. Setelah berhasil, Anda akan langsung masuk ke beranda aplikasi dan dapat mulai mengisi detail pernikahan.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "gs-2",
            topic: .gettingStarted,
            title: "Login dengan email atau Google",
            summary: "Cara masuk ke akun yang sudah terdaftar.",
            body: """
            Buka halaman Masuk, lalu masukkan email dan kata sandi Anda. Jika Anda mendaftar lewat Google, pilih tombol Lanjutkan dengan Google.

            Pastikan koneksi internet aktif. Jika lupa kata sandi, gunakan fitur Lupa kata sandi di halaman login untuk memulihkan akses akun.
            """,
            readMinutes: 2
        ),
        HelpArticle(
            id: "gs-3",
            topic: .gettingStarted,
            title: "Mengisi profil pasangan",
            summary: "Lengkapi nama mempelai dan informasi dasar pasangan.",
            body: """
            Buka menu Lainnya, pilih Pasangan, lalu isi nama mempelai wanita dan pria. Anda juga dapat menambahkan budaya atau konsep pernikahan.

            Informasi ini akan tampil di beranda dan halaman Detail Pernikahan sehingga seluruh rencana terasa lebih personal.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "gs-4",
            topic: .gettingStarted,
            title: "Navigasi menu utama aplikasi",
            summary: "Kenali tab Beranda, Checklist, Tamu, Budget, dan Lainnya.",
            body: """
            Beranda menampilkan ringkasan progres pernikahan. Checklist berisi tugas persiapan. Tamu untuk mengelola daftar undangan. Budget untuk mencatat pengeluaran dan uang masuk.

            Menu Lainnya berisi pengaturan akun, dokumen, inspirasi, privasi, dan bantuan. Gunakan tab bawah untuk berpindah antar fitur utama dengan cepat.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "gs-5",
            topic: .gettingStarted,
            title: "Mengatur detail pernikahan",
            summary: "Atur tanggal, lokasi, dan rangkaian acara pernikahan.",
            body: """
            Dari menu Lainnya, buka Detail Pernikahan. Di sana Anda dapat melihat ringkasan acara, jadwal, dan daftar tamu.

            Ketuk Edit untuk memperbarui tanggal, lokasi, konsep pernikahan, serta catatan penting yang ingin dibagikan ke vendor atau keluarga.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "gs-6",
            topic: .gettingStarted,
            title: "Tips memulai perencanaan dengan baik",
            summary: "Langkah awal yang disarankan untuk pasangan baru.",
            body: """
            Mulailah dengan mengisi detail pernikahan dan checklist prioritas 3 bulan pertama. Tentukan budget kasar, lalu catat vendor utama yang sudah dihubungi.

            Manfaatkan fitur inspirasi untuk mengumpulkan referensi dekorasi, gaun, dan venue. Rencanakan sedikit demi sedikit agar persiapan tetap terkendali.
            """,
            readMinutes: 5
        ),
    ]

    private static let preparationArticles: [HelpArticle] = [
        HelpArticle(
            id: "prep-1",
            topic: .preparation,
            title: "Memahami checklist persiapan",
            summary: "Cara membaca dan menggunakan checklist di aplikasi.",
            body: """
            Checklist membantu Anda melacak tugas persiapan dari awal hingga hari H. Setiap tugas memiliki status: Belum Mulai, Berjalan, atau Selesai.

            Gunakan filter dan pencarian untuk menemukan tugas tertentu. Progress keseluruhan ditampilkan di bagian atas agar Anda tahu seberapa jauh persiapan sudah berjalan.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "prep-2",
            topic: .preparation,
            title: "Menyelesaikan tugas dan sub-tugas",
            summary: "Tandai progres dan kelola detail setiap tugas.",
            body: """
            Ketuk tugas untuk melihat detail lengkap. Di dalamnya Anda dapat membaca deskripsi, mengubah status, dan mengerjakan sub-tugas satu per satu.

            Tandai sub-tugas sebagai selesai agar progress tugas induk ikut terupdate. Ini memudahkan Anda membagi pekerjaan besar menjadi langkah-langkah kecil.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "prep-3",
            topic: .preparation,
            title: "Melampirkan dokumen di checklist",
            summary: "Simpan kontrak, invoice, dan file penting per tugas.",
            body: """
            Setiap tugas dapat memiliki lampiran seperti PDF, JPG, atau PNG. File yang dilampirkan juga dapat muncul di menu Dokumen untuk akses cepat.

            Gunakan lampiran untuk menyimpan kontrak vendor, bukti pembayaran, atau referensi desain agar semua informasi berada di satu tempat.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "prep-4",
            topic: .preparation,
            title: "Mengatur timeline persiapan",
            summary: "Prioritaskan tugas berdasarkan waktu menuju pernikahan.",
            body: """
            Lihat tugas yang memiliki target selesai terdekat di beranda pada bagian Selanjutnya. Urutkan checklist berdasarkan prioritas atau deadline.

            Fokuskan energi pada tugas kritis seperti booking venue, catering, dan dokumentasi terlebih dahulu sebelum menangani detail dekoratif.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "prep-5",
            topic: .preparation,
            title: "Tips persiapan 3 bulan sebelum pernikahan",
            summary: "Checklist penting yang sebaiknya sudah selesai.",
            body: """
            Tiga bulan sebelum acara, pastikan vendor utama sudah dikonfirmasi, jadwal fitting selesai, dan daftar tamu mulai dirapikan.

            Tinjau budget secara berkala, finalisasi rundown acara, dan pastikan semua pembayaran termin vendor tercatat di aplikasi.
            """,
            readMinutes: 5
        ),
        HelpArticle(
            id: "prep-6",
            topic: .preparation,
            title: "Tips persiapan 1 bulan sebelum pernikahan",
            summary: "Hal-hal yang perlu dicek menjelang hari H.",
            body: """
            Satu bulan sebelum pernikahan, konfirmasi ulang semua vendor, cek jumlah tamu yang hadir, dan pastikan dokumen penting sudah lengkap.

            Siapkan catatan khusus untuk hari H, termasuk kontak vendor, alur acara, dan daftar barang yang harus dibawa ke venue.
            """,
            readMinutes: 5
        ),
        HelpArticle(
            id: "prep-7",
            topic: .preparation,
            title: "Menyimpan vendor pilihan",
            summary: "Kelola daftar vendor yang sedang Anda pertimbangkan.",
            body: """
            Saat menjelajahi tab Vendor, simpan vendor favorit Anda agar mudah dibandingkan nanti. Vendor tersimpan dapat diakses dari menu Lainnya.

            Catat juga komunikasi dengan vendor melalui fitur Pesan agar semua kesepakatan terdokumentasi dengan rapi.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "prep-8",
            topic: .preparation,
            title: "Menyimpan inspirasi pernikahan",
            summary: "Kumpulkan ide dekorasi, gaun, dan konsep acara.",
            body: """
            Buka Inspirasi & Ide untuk melihat referensi terbaru. Ketuk Simpan pada ide yang Anda suka agar bisa dibuka kembali kapan saja.

            Gunakan kategori seperti Dekorasi, Gaun, Makeup, Katering, dan Venue untuk mengorganisir inspirasi sesuai kebutuhan perencanaan.
            """,
            readMinutes: 3
        ),
    ]

    private static let budgetArticles: [HelpArticle] = [
        HelpArticle(
            id: "bud-1",
            topic: .budget,
            title: "Mengatur total budget pernikahan",
            summary: "Tetapkan anggaran keseluruhan rencana pernikahan.",
            body: """
            Buka tab Budget untuk melihat ringkasan anggaran. Atur total budget sesuai rencana keuangan Anda agar pengeluaran lebih terkontrol.

            Setelah total budget ditetapkan, Anda dapat melihat sisa anggaran, komitmen pembayaran, dan pengeluaran yang sudah terjadi secara real-time.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "bud-2",
            topic: .budget,
            title: "Menambahkan pengeluaran (expense)",
            summary: "Catat setiap biaya yang sudah atau akan dikeluarkan.",
            body: """
            Ketuk Tambah Expense, lalu isi nama pengeluaran, kategori, nominal, dan tanggal jatuh tempo jika ada.

            Setiap expense yang tersimpan akan masuk ke ringkasan per kategori sehingga Anda tahu bagian mana yang paling banyak menyerap anggaran.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "bud-3",
            topic: .budget,
            title: "Mengelola kategori anggaran",
            summary: "Alokasikan budget per kategori seperti venue, catering, dan dekorasi.",
            body: """
            Gunakan fitur Kategori Budget untuk membagi anggaran ke beberapa kategori utama. Anda dapat menyesuaikan alokasi sesuai prioritas pernikahan.

            Pantau apakah pengeluaran aktual sudah mendekati batas kategori agar tidak ada kejutan di akhir perencanaan.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "bud-4",
            topic: .budget,
            title: "Mencatat uang masuk dan hadiah",
            summary: "Catat amplop, transfer, dan bantuan finansial lainnya.",
            body: """
            Selain pengeluaran, Anda juga dapat mencatat uang masuk dari keluarga atau hadiah tunai. Ini membantu melihat keseimbangan keuangan pernikahan secara menyeluruh.

            Pastikan setiap pencatatan disertai keterangan sumber dan tanggal agar laporan lebih akurat.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "bud-5",
            topic: .budget,
            title: "Jadwal pembayaran vendor",
            summary: "Kelola termin dan tanggal bayar ke vendor.",
            body: """
            Di bagian jadwal pembayaran, catat kapan pembayaran ke vendor harus dilakukan. Tandai status pembayaran agar tidak ada termin yang terlewat.

            Kombinasikan jadwal ini dengan checklist persiapan agar pembayaran dan progress vendor selaras.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "bud-6",
            topic: .budget,
            title: "Membaca ringkasan pengeluaran",
            summary: "Pahami grafik dan statistik budget Anda.",
            body: """
            Ringkasan anggaran menampilkan total budget, terpakai, komitmen, dan sisa anggaran dalam bentuk angka dan persentase.

            Gunakan informasi ini saat evaluasi mingguan untuk memutuskan apakah perlu menyesuaikan vendor, jumlah tamu, atau konsep acara.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "bud-7",
            topic: .budget,
            title: "Tips menghemat budget pernikahan",
            summary: "Strategi praktis menjaga anggaran tetap sehat.",
            body: """
            Tetapkan prioritas 3 hal terpenting, lalu alokasikan budget terbesar di sana. Bandingkan minimal 2–3 vendor sebelum memutuskan.

            Catat semua pengeluaran kecil karena seringkali yang terlewat justru menambah beban. Review budget setiap minggu agar tetap on track.
            """,
            readMinutes: 5
        ),
    ]

    private static let guestsArticles: [HelpArticle] = [
        HelpArticle(
            id: "gst-1",
            topic: .guests,
            title: "Menambahkan tamu ke daftar",
            summary: "Cara mencatat tamu beserta kontaknya.",
            body: """
            Buka tab Tamu, lalu ketuk Tambah Tamu. Isi nama, nomor telepon, email, dan grup tamu jika diperlukan.

            Semakin lengkap data tamu, semakin mudah Anda mengirim undangan dan melacak konfirmasi kehadiran.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "gst-2",
            topic: .guests,
            title: "Mengelola status RSVP tamu",
            summary: "Pantau tamu yang sudah konfirmasi, pending, atau tidak hadir.",
            body: """
            Setiap tamu memiliki status RSVP: Konfirmasi, Pending, atau Tidak Hadir. Ringkasan RSVP ditampilkan di bagian atas halaman Tamu.

            Perbarui status secara berkala agar perhitungan kursi, catering, dan souvenir lebih akurat.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "gst-3",
            topic: .guests,
            title: "Mengundang tamu via WhatsApp",
            summary: "Bagikan undangan digital langsung ke kontak tamu.",
            body: """
            Pastikan nomor WhatsApp tamu sudah diisi. Dari detail tamu, Anda dapat membagikan undangan atau pesan konfirmasi kehadiran.

            Sertakan informasi tanggal, lokasi, dan link undangan digital agar tamu mudah memahami detail acara.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "gst-4",
            topic: .guests,
            title: "Mengelompokkan tamu",
            summary: "Atur tamu berdasarkan keluarga, teman, atau kolega.",
            body: """
            Gunakan field grup atau catatan untuk mengelompokkan tamu. Pengelompokan membantu saat menentukan meja, zona duduk, atau prioritas undangan.

            Anda juga dapat mencari tamu berdasarkan nama atau grup menggunakan kolom pencarian.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "gst-5",
            topic: .guests,
            title: "Melacak jumlah tamu hadir",
            summary: "Gunakan ringkasan tamu untuk estimasi akomodasi.",
            body: """
            Lihat total tamu dan jumlah yang sudah konfirmasi di ringkasan RSVP. Data ini juga tersedia di halaman Detail Pernikahan pada tab Tamu.

            Gunakan angka tersebut untuk koordinasi dengan venue dan katering agar porsi dan tempat duduk sesuai kebutuhan.
            """,
            readMinutes: 3
        ),
    ]

    private static let securityArticles: [HelpArticle] = [
        HelpArticle(
            id: "sec-1",
            topic: .security,
            title: "Mengubah kata sandi akun",
            summary: "Perbarui kata sandi untuk menjaga keamanan akun.",
            body: """
            Buka Lainnya → Privasi & Keamanan → Ubah Kata Sandi. Masukkan kata sandi saat ini, lalu kata sandi baru minimal 8 karakter.

            Setelah kata sandi diubah, sesi login di perangkat lain akan diakhiri otomatis demi keamanan akun Anda.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "sec-2",
            topic: .security,
            title: "Kelola sesi aktif perangkat",
            summary: "Lihat dan akhiri sesi login di perangkat lain.",
            body: """
            Di menu Sesi Aktif, Anda dapat melihat daftar perangkat yang sedang login ke akun. Jika ada perangkat yang tidak dikenal, akhiri sesinya segera.

            Setelah mengakhiri sesi mencurigakan, sebaiknya ubah kata sandi Anda sebagai langkah pencegahan tambahan.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "sec-3",
            topic: .security,
            title: "Privasi data pribadi Anda",
            summary: "Bagaimana Wedding App melindungi informasi Anda.",
            body: """
            Data pernikahan, tamu, dan dokumen Anda hanya dapat diakses oleh akun yang login. Kami menerapkan standar keamanan untuk melindungi informasi pribadi.

            Baca Kebijakan Privasi di menu Privasi & Keamanan untuk detail lengkap tentang pengumpulan dan penggunaan data.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "sec-4",
            topic: .security,
            title: "Login dengan Google atau Apple",
            summary: "Keamanan akun yang masuk lewat metode sosial.",
            body: """
            Jika Anda login menggunakan Google atau Apple, autentikasi dikelola oleh penyedia tersebut. Ubah kata sandi tidak tersedia langsung di aplikasi untuk metode login ini.

            Untuk keamanan, pastikan akun Google atau Apple Anda juga dilindungi dengan verifikasi dua langkah.
            """,
            readMinutes: 3
        ),
        HelpArticle(
            id: "sec-5",
            topic: .security,
            title: "Menghapus akun secara permanen",
            summary: "Cara menghapus akun dan seluruh data terkait.",
            body: """
            Buka Privasi & Keamanan → Hapus Akun. Konfirmasi dengan mengetik HAPUS dan masukkan kata sandi jika diperlukan.

            Penghapusan bersifat permanen. Semua data pernikahan, tamu, budget, dan dokumen akan hilang dan tidak dapat dipulihkan.
            """,
            readMinutes: 4
        ),
        HelpArticle(
            id: "sec-6",
            topic: .security,
            title: "Mengunduh data saya",
            summary: "Ekspor salinan data pribadi Anda.",
            body: """
            Fitur Unduh Data Saya memungkinkan Anda mengekspor salinan informasi akun dan data pernikahan yang tersimpan.

            Gunakan fitur ini jika Anda ingin menyimpan arsip pribadi atau memindahkan data sebelum menutup akun.
            """,
            readMinutes: 3
        ),
    ]
}
