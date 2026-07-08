<?php

namespace App\Support;

class TermsOfServiceContent
{
    public static function lastUpdated(): string
    {
        return '8 Juli 2026';
    }

    public static function introduction(): string
    {
        return 'Syarat & Ketentuan ini mengatur penggunaan Anda atas aplikasi mobile Wedding App dan layanan terkait yang disediakan oleh PT Makna Kreatif Indonesia ("kami"). Dengan mendaftar, mengakses, atau menggunakan Wedding App, Anda dianggap telah membaca, memahami, dan menyetujui seluruh ketentuan berikut.';
    }

    /**
     * @return array<int, array{title: string, paragraphs: array<int, string>, bullets: array<int, string>}>
     */
    public static function sections(): array
    {
        $contactEmail = config('wedding.brand.contact_email');
        $websiteDisplay = config('wedding.brand.website_display');
        $developer = config('wedding.brand.developer');

        return [
            [
                'title' => '1. Penerimaan Syarat',
                'paragraphs' => [
                    'Dengan menggunakan Wedding App, Anda menyetujui Syarat & Ketentuan ini serta Kebijakan Privasi kami. Jika Anda tidak setuju, mohon tidak menggunakan layanan ini.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '2. Definisi',
                'paragraphs' => ['Dalam dokumen ini:'],
                'bullets' => [
                    '"Aplikasi" berarti aplikasi mobile Wedding App dan fitur-fitur di dalamnya.',
                    '"Pengguna" berarti individu yang mendaftar dan menggunakan Aplikasi.',
                    '"Layanan" berarti seluruh fitur perencanaan pernikahan yang disediakan melalui Aplikasi.',
                    '"Konten Pengguna" berarti data, teks, foto, dokumen, dan informasi lain yang Anda unggah atau simpan di Aplikasi.',
                ],
            ],
            [
                'title' => '3. Akun dan Kelayakan',
                'paragraphs' => [
                    'Untuk menggunakan fitur tertentu, Anda harus membuat akun dengan informasi yang akurat dan terkini. Anda bertanggung jawab menjaga kerahasiaan kredensial akun dan seluruh aktivitas yang terjadi melalui akun Anda.',
                ],
                'bullets' => [
                    'Anda harus berusia minimal 17 tahun atau menggunakan Aplikasi di bawah pengawasan orang tua/wali yang sah.',
                    'Satu akun hanya boleh digunakan oleh pengguna yang berwenang dan tidak boleh dibagikan kepada pihak lain tanpa izin.',
                    'Kami berhak menangguhkan atau menutup akun yang melanggar Syarat & Ketentuan ini.',
                ],
            ],
            [
                'title' => '4. Penggunaan Layanan',
                'paragraphs' => [
                    'Wedding App menyediakan alat bantu perencanaan pernikahan, termasuk namun tidak terbatas pada checklist, manajemen tamu, anggaran, dokumen, inspirasi, dan komunikasi support.',
                ],
                'bullets' => [
                    'Layanan disediakan untuk keperluan pribadi dan non-komersial dalam konteks perencanaan pernikahan.',
                    'Kami dapat menambah, mengubah, atau menghentikan fitur tertentu untuk meningkatkan layanan atau keamanan.',
                    'Ketersediaan layanan dapat terpengaruh oleh pemeliharaan sistem, gangguan jaringan, atau faktor di luar kendali kami.',
                ],
            ],
            [
                'title' => '5. Konten Pengguna',
                'paragraphs' => [
                    'Anda tetap memiliki hak atas Konten Pengguna yang Anda unggah. Dengan menggunakan Aplikasi, Anda memberikan lisensi terbatas kepada kami untuk menyimpan, memproses, dan menampilkan konten tersebut semata-mata untuk menyediakan Layanan.',
                ],
                'bullets' => [
                    'Anda menjamin bahwa konten yang diunggah tidak melanggar hukum, hak pihak ketiga, atau norma yang berlaku.',
                    'Anda bertanggung jawab atas keakuratan data pernikahan, tamu, anggaran, dan informasi lain yang Anda masukkan.',
                    'Kami dapat menghapus konten yang melanggar hukum atau Syarat & Ketentuan ini.',
                ],
            ],
            [
                'title' => '6. Vendor dan Layanan Pihak Ketiga',
                'paragraphs' => [
                    'Aplikasi dapat menampilkan informasi vendor atau menghubungkan Anda ke layanan pihak ketiga. Kami tidak bertanggung jawab atas kualitas, harga, ketersediaan, atau kinerja layanan pihak ketiga tersebut.',
                ],
                'bullets' => [
                    'Transaksi atau kesepakatan dengan vendor dilakukan di luar tanggung jawab langsung Wedding App, kecuali dinyatakan lain secara tertulis.',
                    'Autentikasi melalui Google atau Apple tunduk pada ketentuan masing-masing penyedia layanan.',
                ],
            ],
            [
                'title' => '7. Hak Kekayaan Intelektual',
                'paragraphs' => [
                    'Seluruh merek dagang, logo, desain antarmuka, kode, dan materi lain dalam Aplikasi (selain Konten Pengguna) adalah milik kami atau pemberi lisensi kami dan dilindungi oleh hukum yang berlaku.',
                ],
                'bullets' => [
                    'Anda tidak diperkenankan menyalin, memodifikasi, mendistribusikan, atau melakukan reverse engineering atas Aplikasi tanpa izin tertulis.',
                ],
            ],
            [
                'title' => '8. Larangan Penggunaan',
                'paragraphs' => ['Anda dilarang menggunakan Aplikasi untuk:'],
                'bullets' => [
                    'Aktivitas ilegal, penipuan, pelecehan, atau pelanggaran hak pihak lain.',
                    'Mengunggah malware, spam, atau konten yang mengandung kebencian, pornografi, atau kekerasan.',
                    'Mencoba mengakses sistem, akun, atau data pengguna lain tanpa izin.',
                    'Mengganggu stabilitas atau keamanan server dan infrastruktur kami.',
                ],
            ],
            [
                'title' => '9. Penafian dan Batasan Tanggung Jawab',
                'paragraphs' => [
                    'Aplikasi disediakan "sebagaimana adanya". Kami berupaya menjaga akurasi dan ketersediaan layanan, namun tidak menjamin bahwa Aplikasi bebas dari kesalahan atau gangguan.',
                    'Sejauh diizinkan oleh hukum, kami tidak bertanggung jawab atas kerugian tidak langsung, kehilangan data akibat kelalaian pengguna, atau keputusan pernikahan yang diambil berdasarkan informasi di Aplikasi.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '10. Penghentian Layanan',
                'paragraphs' => [
                    'Anda dapat berhenti menggunakan Aplikasi kapan saja dan menghapus akun melalui menu Privasi & Keamanan. Kami dapat menangguhkan atau menghentikan akses Anda jika terjadi pelanggaran terhadap Syarat & Ketentuan ini atau untuk kepatuhan hukum.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '11. Perubahan Syarat & Ketentuan',
                'paragraphs' => [
                    'Kami dapat memperbarui Syarat & Ketentuan ini dari waktu ke waktu. Perubahan material akan diberitahukan melalui Aplikasi atau email. Penggunaan berkelanjutan setelah pembaruan dianggap sebagai persetujuan Anda.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '12. Hukum yang Berlaku',
                'paragraphs' => [
                    'Syarat & Ketentuan ini diatur oleh dan ditafsirkan sesuai hukum Republik Indonesia. Sengketa yang timbul akan diselesaikan melalui musyawarah terlebih dahulu, dan apabila diperlukan melalui pengadilan yang berwenang di Indonesia.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '13. Hubungi Kami',
                'paragraphs' => [
                    'Jika Anda memiliki pertanyaan tentang Syarat & Ketentuan ini, silakan hubungi:',
                    "{$developer}\nEmail: {$contactEmail}\nWebsite: {$websiteDisplay}",
                ],
                'bullets' => [],
            ],
        ];
    }
}
