<?php

namespace App\Support;

class PrivacyPolicyContent
{
    public static function lastUpdated(): string
    {
        return '8 Juli 2026';
    }

    public static function introduction(): string
    {
        return 'Kebijakan Privasi ini menjelaskan bagaimana Wedding App ("kami") mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Anda saat menggunakan aplikasi mobile Wedding App dan layanan terkait.';
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
                'title' => '1. Data yang Kami Kumpulkan',
                'paragraphs' => [
                    'Kami dapat mengumpulkan data berikut saat Anda menggunakan Wedding App:',
                ],
                'bullets' => [
                    'Data akun: nama, alamat email, kata sandi (terenkripsi), foto profil, nomor WhatsApp, serta informasi autentikasi dari Google atau Apple jika Anda masuk dengan metode tersebut.',
                    'Data pernikahan: nama pasangan, tanggal dan detail acara, lokasi, budaya/adat, daftar tamu, anggaran, dokumen, checklist persiapan, dan informasi vendor yang Anda simpan.',
                    'Data komunikasi: pesan support, topik pertanyaan, serta riwayat percakapan dengan tim Wedding App.',
                    'Data perangkat: token push notification, nama perangkat, informasi sesi login, dan log teknis untuk keamanan aplikasi.',
                    'Data penggunaan: preferensi notifikasi, interaksi fitur, serta data yang Anda unggah secara sukarela ke aplikasi.',
                ],
            ],
            [
                'title' => '2. Cara Kami Menggunakan Data',
                'paragraphs' => [
                    'Data pribadi Anda digunakan untuk tujuan berikut:',
                ],
                'bullets' => [
                    'Menyediakan, mengoperasikan, dan meningkatkan fitur perencanaan pernikahan di aplikasi.',
                    'Mengelola akun Anda, autentikasi, dan keamanan sesi.',
                    'Mengirim notifikasi terkait aktivitas akun, balasan support, dan pengingat pernikahan sesuai pengaturan Anda.',
                    'Memberikan dukungan pelanggan dan menanggapi pertanyaan atau permintaan Anda.',
                    'Menganalisis penggunaan aplikasi secara agregat untuk meningkatkan pengalaman pengguna.',
                    'Memenuhi kewajiban hukum dan mencegah penyalahgunaan layanan.',
                ],
            ],
            [
                'title' => '3. Dasar Pemrosesan Data',
                'paragraphs' => [
                    'Kami memproses data pribadi Anda berdasarkan:',
                ],
                'bullets' => [
                    'Persetujuan Anda saat mendaftar dan menggunakan fitur tertentu.',
                    'Pelaksanaan perjanjian layanan antara Anda dan Wedding App.',
                    'Kepentingan sah kami untuk menjaga keamanan, mencegah penipuan, dan meningkatkan layanan.',
                    'Kewajiban hukum yang berlaku di Indonesia.',
                ],
            ],
            [
                'title' => '4. Berbagi Data dengan Pihak Ketiga',
                'paragraphs' => [
                    'Kami tidak menjual data pribadi Anda. Data hanya dapat dibagikan dalam kondisi berikut:',
                ],
                'bullets' => [
                    'Penyedia layanan teknis yang membantu operasional aplikasi (misalnya hosting, autentikasi, push notification), dengan kewajiban kerahasiaan.',
                    'Vendor atau pihak ketiga hanya jika Anda secara eksplisit berinteraksi melalui fitur aplikasi.',
                    'Otoritas hukum apabila diwajibkan oleh peraturan perundang-undangan yang berlaku.',
                    'Proses bisnis seperti merger atau akuisisi, dengan pemberitahuan kepada pengguna jika diperlukan.',
                ],
            ],
            [
                'title' => '5. Penyimpanan dan Keamanan Data',
                'paragraphs' => [
                    'Kami menerapkan langkah keamanan teknis dan organisasi yang wajar untuk melindungi data Anda dari akses, perubahan, pengungkapan, atau penghancuran yang tidak sah.',
                    'Data disimpan selama akun Anda aktif atau selama diperlukan untuk menyediakan layanan dan memenuhi kewajiban hukum. Anda dapat meminta penghapusan akun melalui menu Privasi & Keamanan di aplikasi.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '6. Hak Anda sebagai Pengguna',
                'paragraphs' => [
                    'Sesuai peraturan yang berlaku, Anda berhak untuk:',
                ],
                'bullets' => [
                    'Mengakses dan memperbarui data profil serta detail pernikahan melalui aplikasi.',
                    'Menarik persetujuan notifikasi push melalui pengaturan perangkat atau aplikasi.',
                    'Meminta salinan data pribadi Anda (fitur unduh data).',
                    'Menghapus akun dan data terkait melalui menu Hapus Akun.',
                    'Menghubungi kami untuk pertanyaan atau keberatan terkait pemrosesan data pribadi.',
                ],
            ],
            [
                'title' => '7. Cookie, Token, dan Teknologi Serupa',
                'paragraphs' => [
                    'Aplikasi mobile dapat menyimpan token autentikasi secara aman di perangkat Anda serta token push notification untuk mengirim pemberitahuan. Anda dapat menghapus token tersebut dengan logout atau mencabut izin notifikasi di pengaturan perangkat.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '8. Privasi Anak',
                'paragraphs' => [
                    'Wedding App tidak ditujukan untuk anak di bawah 17 tahun tanpa pengawasan orang tua atau wali. Kami tidak dengan sengaja mengumpulkan data pribadi dari anak tanpa persetujuan yang sah.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '9. Perubahan Kebijakan Privasi',
                'paragraphs' => [
                    'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan material akan diberitahukan melalui aplikasi atau email. Tanggal pembaruan terakhir tercantum di bagian atas halaman ini.',
                ],
                'bullets' => [],
            ],
            [
                'title' => '10. Hubungi Kami',
                'paragraphs' => [
                    'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini atau ingin menggunakan hak privasi Anda, silakan hubungi:',
                    "{$developer}\nEmail: {$contactEmail}\nWebsite: {$websiteDisplay}",
                ],
                'bullets' => [],
            ],
        ];
    }
}
