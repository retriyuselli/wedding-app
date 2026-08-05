<?php

namespace App\Support;

class HelpContent
{
    public static function supportEmail(): string
    {
        return (string) config('wedding.brand.support_email', 'support@weddingapp.co.id');
    }

    public static function supportWhatsapp(): string
    {
        return (string) config('wedding.brand.support_whatsapp', '+62 812 3456 7890');
    }

    public static function supportWhatsappUrl(): string
    {
        $digits = preg_replace('/\D+/', '', self::supportWhatsapp()) ?? '';

        return 'https://wa.me/'.$digits;
    }

    public static function appVersion(): string
    {
        return '1.2.3';
    }

    public static function lastUpdatedLabel(): string
    {
        return '10 Mei 2024';
    }

    /**
     * @return array<int, array{
     *     id: string,
     *     question: string,
     *     answer: string,
     *     icon: string
     * }>
     */
    public static function faqs(): array
    {
        return [
            [
                'id' => 'create-wedding',
                'question' => 'Bagaimana cara membuat pernikahan baru di Wedding App?',
                'answer' => 'Setelah mendaftar, buka menu Profil lalu lengkapi Detail Pernikahan. Isi nama mempelai, tanggal acara, lokasi, dan jenis acara. Data ini akan digunakan di beranda, checklist, dan fitur lainnya.',
                'icon' => 'heart',
            ],
            [
                'id' => 'add-guest',
                'question' => 'Bagaimana cara menambahkan tamu ke daftar guest?',
                'answer' => 'Buka halaman Guest, lalu ketuk tombol tambah tamu. Isi nama, kontak, dan kategori tamu. Anda dapat memperbarui status RSVP kapan saja dari daftar tamu.',
                'icon' => 'users',
            ],
            [
                'id' => 'add-expense',
                'question' => 'Bagaimana cara menambahkan pengeluaran (expense) di budget?',
                'answer' => 'Masuk ke halaman Budget, pilih kategori anggaran yang sesuai, lalu tambahkan jadwal pembayaran atau pengeluaran baru. Isi nominal, tanggal, dan status pembayaran agar laporan anggaran tetap akurat.',
                'icon' => 'wallet',
            ],
            [
                'id' => 'download-report',
                'question' => 'Apakah saya bisa mengunduh checklist atau laporan?',
                'answer' => 'Saat ini Anda dapat mengunduh dokumen yang dilampirkan di checklist dan menu Dokumen. Fitur ekspor checklist atau laporan lengkap sedang kami siapkan untuk pembaruan berikutnya.',
                'icon' => 'download',
            ],
            [
                'id' => 'edit-wedding',
                'question' => 'Bagaimana cara mengubah detail pernikahan?',
                'answer' => 'Buka Profil, lalu scroll ke bagian Detail Pernikahan atau gunakan menu pengaturan di sidebar kanan. Perbarui nama mempelai, budaya, atau informasi akun, lalu simpan perubahan.',
                'icon' => 'pencil',
            ],
            [
                'id' => 'delete-account',
                'question' => 'Bagaimana cara menghapus akun saya?',
                'answer' => 'Untuk keamanan data, penghapusan akun dilakukan melalui tim support. Hubungi kami via email atau WhatsApp dengan menyertakan email akun Anda. Kami akan memproses permintaan sesuai kebijakan privasi.',
                'icon' => 'trash',
            ],
        ];
    }

    /**
     * @return array<int, array{
     *     id: string,
     *     title: string,
     *     description: string,
     *     icon: string,
     *     icon_bg: string,
     *     icon_text: string,
     *     route: string
     * }>
     */
    public static function topics(): array
    {
        return [
            [
                'id' => 'memulai',
                'title' => 'Memulai',
                'description' => 'Panduan awal menggunakan Wedding App.',
                'icon' => 'book',
                'icon_bg' => 'bg-sage-50',
                'icon_text' => 'text-sage-700',
                'route' => 'dashboard',
            ],
            [
                'id' => 'checklist',
                'title' => 'Checklist',
                'description' => 'Kelola checklist persiapan pernikahan dengan mudah.',
                'icon' => 'checklist',
                'icon_bg' => 'bg-sky-50',
                'icon_text' => 'text-sky-600',
                'route' => 'checklist',
            ],
            [
                'id' => 'guest',
                'title' => 'Guest',
                'description' => 'Undangan digital dan manajemen daftar tamu.',
                'icon' => 'users',
                'icon_bg' => 'bg-violet-50',
                'icon_text' => 'text-violet-600',
                'route' => 'tamu',
            ],
            [
                'id' => 'budget',
                'title' => 'Budget',
                'description' => 'Catat pengeluaran dan kelola anggaran pernikahan.',
                'icon' => 'wallet',
                'icon_bg' => 'bg-amber-50',
                'icon_text' => 'text-amber-600',
                'route' => 'biaya',
            ],
            [
                'id' => 'subscription',
                'title' => 'Paket & Langganan',
                'description' => 'Informasi paket premium dan cara berlangganan.',
                'icon' => 'sparkle',
                'icon_bg' => 'bg-rose-50',
                'icon_text' => 'text-rose-500',
                'route' => 'profil',
            ],
            [
                'id' => 'account',
                'title' => 'Akun & Profil',
                'description' => 'Kelola profil, pengaturan akun, dan keamanan.',
                'icon' => 'user',
                'icon_bg' => 'bg-teal-50',
                'icon_text' => 'text-teal-600',
                'route' => 'profil',
            ],
            [
                'id' => 'troubleshooting',
                'title' => 'Troubleshooting',
                'description' => 'Solusi untuk masalah umum yang sering terjadi.',
                'icon' => 'wrench',
                'icon_bg' => 'bg-orange-50',
                'icon_text' => 'text-orange-600',
                'route' => 'bantuan',
            ],
            [
                'id' => 'features',
                'title' => 'Fitur Lainnya',
                'description' => 'Pelajari fitur lain yang tersedia di Wedding App.',
                'icon' => 'grid',
                'icon_bg' => 'bg-gray-100',
                'icon_text' => 'text-gray-600',
                'route' => 'dashboard',
            ],
        ];
    }

    /**
     * @return array<int, array{title: string, route: string}>
     */
    public static function popularGuides(): array
    {
        return [
            ['title' => 'Cara Menambahkan Pernikahan Baru', 'route' => 'profil'],
            ['title' => 'Cara Mengelola Checklist', 'route' => 'checklist'],
            ['title' => 'Cara Mengundang Tamu', 'route' => 'tamu'],
            ['title' => 'Cara Menambahkan Pengeluaran', 'route' => 'biaya'],
            ['title' => 'Cara Berlangganan Premium', 'route' => 'profil'],
        ];
    }

    /**
     * @return array<int, array{
     *     id: string,
     *     title: string,
     *     subtitle: string,
     *     action: string,
     *     href: string,
     *     external: bool
     * }>
     */
    public static function contactMethods(): array
    {
        return [
            [
                'id' => 'chat',
                'title' => 'Live Chat',
                'subtitle' => 'Respon cepat pada jam kerja',
                'action' => 'Mulai Chat',
                'href' => '#',
                'external' => false,
            ],
            [
                'id' => 'whatsapp',
                'title' => 'WhatsApp',
                'subtitle' => self::supportWhatsapp(),
                'action' => 'Kirim Pesan',
                'href' => self::supportWhatsappUrl(),
                'external' => true,
            ],
            [
                'id' => 'email',
                'title' => 'Email',
                'subtitle' => self::supportEmail(),
                'action' => 'Kirim Email',
                'href' => 'mailto:'.self::supportEmail(),
                'external' => true,
            ],
        ];
    }
}
