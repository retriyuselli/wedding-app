<?php

namespace Database\Seeders;

use App\Models\CustomerPreparationSection;
use App\Models\CustomerPreparationTask;
use App\Models\User;
use App\Models\WeddingEvent;
use Illuminate\Database\Seeder;

class WeddingPreparationChecklistSeeder extends Seeder
{
    /**
     * Seed daftar persiapan (section + task) per jenis acara pernikahan.
     * Sumber data mengikuti checklist di folder `wedding-event/*.md`.
     */
    public function run(): void
    {
        $checklists = $this->checklists();

        User::all()->each(function (User $user) use ($checklists): void {
            foreach ($checklists as $jenisAcara => $sections) {
                $event = $user->weddingEvents()
                    ->where('jenis_acara', $jenisAcara)
                    ->first();

                if (! $event instanceof WeddingEvent) {
                    continue;
                }

                $sectionSort = 1;

                foreach ($sections as $section) {
                    $preparationSection = CustomerPreparationSection::create([
                        'user_id' => $user->id,
                        'title' => $section['title'],
                        'icon' => $section['icon'],
                        'sort_order' => $sectionSort++,
                    ]);

                    $taskSort = 1;

                    foreach ($section['tasks'] as $taskTitle) {
                        CustomerPreparationTask::create([
                            'user_id' => $user->id,
                            'wedding_event_id' => $event->id,
                            'section_id' => $preparationSection->id,
                            'title' => $taskTitle,
                            'status' => 'pending',
                            'sort_order' => $taskSort++,
                        ]);
                    }
                }
            }
        });
    }

    /**
     * @return array<string, array<int, array{title: string, icon: string, tasks: array<int, string>}>>
     */
    private function checklists(): array
    {
        return [
            'lamaran' => $this->lamaran(),
            'pengajian' => $this->pengajian(),
            'akad' => $this->akad(),
            'resepsi' => $this->resepsi(),
        ];
    }

    /**
     * @return array<int, array{title: string, icon: string, tasks: array<int, string>}>
     */
    private function lamaran(): array
    {
        return [
            ['title' => 'Kesepakatan Keluarga', 'icon' => 'person.2', 'tasks' => [
                'Menyepakati rencana lamaran antara kedua keluarga',
                'Menentukan tanggal & jam acara lamaran',
                'Menentukan lokasi (rumah pihak wanita / gedung / restoran)',
                'Menyepakati jumlah rombongan yang datang',
                'Menentukan juru bicara (perwakilan) dari masing-masing keluarga',
                'Menyepakati susunan acara lamaran',
            ]],
            ['title' => 'Seserahan & Hantaran', 'icon' => 'gift', 'tasks' => [
                'Menentukan jumlah & jenis hantaran/seserahan',
                'Membeli isi seserahan (kue, buah, pakaian, perlengkapan, dll)',
                'Menyiapkan cincin lamaran/tunangan',
                'Menyiapkan wadah/hampers & menghias seserahan',
                'Menyiapkan pembawa seserahan dari pihak pria',
            ]],
            ['title' => 'Tempat & Dekorasi', 'icon' => 'sparkles', 'tasks' => [
                'Menyiapkan/menata ruang tamu untuk acara',
                'Dekorasi meja & area duduk kedua keluarga',
                'Menyiapkan kursi untuk kedua keluarga',
                'Menyiapkan area untuk memajang seserahan',
                'Backdrop/spot foto sederhana (opsional)',
            ]],
            ['title' => 'Busana', 'icon' => 'tshirt', 'tasks' => [
                'Menentukan dress code/tema warna busana',
                'Menyiapkan busana calon mempelai wanita',
                'Menyiapkan busana calon mempelai pria',
                'Koordinasi busana keluarga inti',
                'Makeup ringan (opsional, booking MUA jika perlu)',
            ]],
            ['title' => 'Konsumsi', 'icon' => 'fork.knife', 'tasks' => [
                'Menentukan jumlah tamu/rombongan',
                'Menyiapkan hidangan utama / katering',
                'Menyiapkan snack & minuman',
                'Menyiapkan hidangan untuk rombongan pihak pria',
                'Kue/buah tangan untuk tamu pulang (opsional)',
            ]],
            ['title' => 'Dokumentasi', 'icon' => 'camera', 'tasks' => [
                'Booking fotografer (atau tunjuk keluarga/teman)',
                'Brief momen wajib: penyerahan seserahan, tukar cincin, foto keluarga',
                'Menyiapkan spot foto bersama',
            ]],
            ['title' => 'Susunan Acara', 'icon' => 'list.bullet.rectangle', 'tasks' => [
                'Pembukaan & sambutan tuan rumah',
                'Sambutan & maksud kedatangan pihak pria',
                'Penyampaian lamaran resmi',
                'Jawaban/penerimaan dari pihak wanita',
                'Penyerahan seserahan',
                'Tukar cincin (jika ada tunangan)',
                'Menyepakati rencana pernikahan (tanggal akad/resepsi)',
                'Doa bersama',
                'Ramah tamah & makan bersama',
                'Sesi foto keluarga',
            ]],
            ['title' => 'Ceklis Hari-H', 'icon' => 'checkmark.circle', 'tasks' => [
                'Konfirmasi ulang kedatangan rombongan (H-1)',
                'Cek kelengkapan seserahan & cincin',
                'Rumah/tempat siap & rapi',
                'Konsumsi siap disajikan',
                'Keluarga inti hadir tepat waktu',
                'Juru bicara siap dengan susunan acara',
                'Dokumentasi berjalan',
                'Serah terima seserahan',
                'Kesepakatan tanggal pernikahan dicatat',
            ]],
        ];
    }

    /**
     * @return array<int, array{title: string, icon: string, tasks: array<int, string>}>
     */
    private function pengajian(): array
    {
        return [
            ['title' => 'Perencanaan Acara', 'icon' => 'calendar', 'tasks' => [
                'Menentukan tanggal & jam pengajian (biasanya H-1 sampai H-3 sebelum akad)',
                'Menentukan lokasi (rumah / masjid / gedung)',
                'Menentukan jumlah tamu undangan',
                'Menyusun rundown acara pengajian',
                'Menyepakati tema/tujuan (doa & syukuran menjelang menikah)',
            ]],
            ['title' => 'Penceramah & Pengisi Acara', 'icon' => 'person.wave.2', 'tasks' => [
                'Mengundang ustadz/penceramah',
                'Konfirmasi jadwal & honor penceramah',
                'Menyiapkan MC/pembawa acara',
                'Mengundang grup hadroh/qasidah (opsional)',
                "Menyiapkan qori/pembaca Al-Qur'an",
                'Menyiapkan pemimpin doa & tahlil',
            ]],
            ['title' => 'Undangan', 'icon' => 'envelope', 'tasks' => [
                'Menyusun daftar tamu (keluarga, tetangga, kerabat)',
                'Menyebar undangan (lisan/tertulis/digital)',
                'Mengundang majelis taklim/jamaah pengajian (jika ada)',
                'Konfirmasi kehadiran tamu penting',
            ]],
            ['title' => 'Tempat & Perlengkapan', 'icon' => 'house', 'tasks' => [
                'Menyiapkan ruangan & alas duduk (karpet/tikar)',
                'Menyiapkan sound system & mic',
                'Menyiapkan meja untuk penceramah',
                "Menyiapkan Al-Qur'an & buku Yasin/tahlil",
                'Dekorasi sederhana bernuansa islami',
                'Menyiapkan area terpisah tamu pria & wanita (jika diperlukan)',
            ]],
            ['title' => 'Busana', 'icon' => 'tshirt', 'tasks' => [
                'Menyiapkan busana muslim/muslimah mempelai',
                'Menyiapkan busana keluarga inti',
                'Menyiapkan mukena & perlengkapan salat',
                'Makeup natural (opsional)',
            ]],
            ['title' => 'Konsumsi', 'icon' => 'fork.knife', 'tasks' => [
                'Menyiapkan hidangan utama / nasi kotak',
                'Menyiapkan snack & minuman untuk tamu',
                'Menyiapkan konsumsi khusus penceramah & pengisi acara',
                'Menyiapkan berkat/bingkisan untuk dibawa pulang tamu',
                'Menyiapkan air minum & kurma (opsional)',
            ]],
            ['title' => 'Dokumentasi', 'icon' => 'camera', 'tasks' => [
                'Booking/tunjuk fotografer',
                'Brief momen wajib: tausiyah, doa bersama, sungkeman (jika ada)',
                'Menyiapkan spot foto keluarga',
            ]],
            ['title' => 'Susunan Acara', 'icon' => 'list.bullet.rectangle', 'tasks' => [
                'Pembukaan oleh MC',
                "Pembacaan ayat suci Al-Qur'an",
                'Sambutan tuan rumah/keluarga',
                'Tausiyah/ceramah dari penceramah',
                'Pembacaan doa, tahlil, & selawat',
                'Prosesi khusus (siraman/sungkeman) jika ada',
                'Ramah tamah & makan bersama',
                'Penutup & pembagian berkat',
            ]],
            ['title' => 'Ceklis Hari-H', 'icon' => 'checkmark.circle', 'tasks' => [
                'Konfirmasi ulang penceramah & pengisi acara (H-1)',
                'Tempat & alas duduk siap',
                'Tes sound system & mic',
                'Konsumsi & berkat siap',
                'Busana & perlengkapan salat siap',
                'Amplop untuk penceramah & pengisi acara disiapkan',
                'Dokumentasi berjalan',
                'Acara berjalan sesuai rundown',
                'Pembagian berkat ke tamu',
            ]],
        ];
    }

    /**
     * @return array<int, array{title: string, icon: string, tasks: array<int, string>}>
     */
    private function akad(): array
    {
        return [
            ['title' => 'Administrasi & Dokumen', 'icon' => 'doc.text', 'tasks' => [
                'Mengurus surat pengantar RT/RW',
                'Mengurus surat N1-N4 dari kelurahan (surat keterangan untuk menikah)',
                'Fotokopi KTP kedua mempelai',
                'Fotokopi KTP kedua orang tua/wali',
                'Fotokopi Kartu Keluarga (KK) kedua mempelai',
                'Fotokopi akta kelahiran kedua mempelai',
                'Pas foto latar biru (ukuran 2x3, 3x4, 4x6) sesuai jumlah yang diminta KUA',
                'Surat rekomendasi nikah dari KUA domisili (jika beda kecamatan)',
                'Fotokopi ijazah terakhir (jika diminta)',
                'Melengkapi surat izin orang tua (jika usia di bawah ketentuan)',
                'Surat keterangan belum menikah / akta cerai / akta kematian pasangan (jika pernah menikah)',
                'Mendaftarkan pernikahan ke KUA (minimal H-10 hari kerja)',
                'Menentukan menikah di KUA atau di luar KUA (perlu bukti bayar PNBP Rp600.000 bila di luar/luar jam kerja)',
            ]],
            ['title' => 'Penghulu & Wali', 'icon' => 'person.badge.shield.checkmark', 'tasks' => [
                'Konfirmasi jadwal penghulu dari KUA',
                'Memastikan wali nikah (ayah kandung / wali nasab)',
                'Menyiapkan wali hakim jika wali berhalangan (koordinasi dengan KUA)',
                'Menentukan 2 orang saksi akad',
                'Menyiapkan surat tugas/taukil wali jika wali diwakilkan',
                'Brief calon mempelai pria untuk ijab kabul (latihan pelafalan)',
            ]],
            ['title' => 'Mahar / Mas Kawin', 'icon' => 'giftcard', 'tasks' => [
                'Menyepakati bentuk mahar (uang tunai, emas, seperangkat alat salat, dll)',
                'Membeli/menyiapkan mahar',
                'Menyiapkan hiasan/mahar box untuk dipajang',
                'Menyiapkan seserahan (jika ada)',
                'Menyiapkan cincin kawin',
            ]],
            ['title' => 'Tempat & Waktu Acara', 'icon' => 'mappin.and.ellipse', 'tasks' => [
                'Menentukan tanggal dan jam akad',
                'Menentukan lokasi akad (rumah, masjid, gedung, atau KUA)',
                'Survei & booking tempat akad',
                'Menyiapkan area khusus untuk prosesi ijab kabul',
                'Menyiapkan kursi mempelai, wali, penghulu, dan saksi',
                'Menyiapkan meja akad + perlengkapan tanda tangan',
                'Cadangan tenda/ruangan jika hujan (outdoor)',
            ]],
            ['title' => 'Dekorasi & Suasana', 'icon' => 'sparkles', 'tasks' => [
                'Booking vendor dekorasi akad',
                'Menentukan tema & warna dekorasi',
                'Dekorasi pelaminan/area akad',
                'Backdrop untuk foto',
                'Rangkaian bunga meja akad',
                'Tata pencahayaan area akad',
            ]],
            ['title' => 'Busana & Perias', 'icon' => 'tshirt', 'tasks' => [
                'Booking MUA (Make Up Artist) untuk akad',
                'Fitting busana akad mempelai wanita',
                'Fitting busana akad mempelai pria',
                'Menyiapkan busana orang tua & keluarga inti',
                'Menyiapkan hijab & aksesori (untuk muslimah)',
                'Jadwal makeup & sanggul hari-H',
                'Menyiapkan alas kaki & perlengkapan busana cadangan',
            ]],
            ['title' => 'Konsumsi', 'icon' => 'fork.knife', 'tasks' => [
                'Menentukan jumlah tamu akad (biasanya keluarga inti & tamu terbatas)',
                'Booking katering / menyiapkan hidangan',
                'Menyiapkan konsumsi untuk penghulu & saksi',
                'Menyiapkan air minum & snack',
                'Menyiapkan hidangan tumpeng/nasi kotak (opsional)',
                'Kue/hantaran untuk syukuran',
            ]],
            ['title' => 'Dokumentasi', 'icon' => 'camera', 'tasks' => [
                'Booking fotografer akad',
                'Booking videografer akad',
                'Brief momen wajib: ijab kabul, penyerahan mahar, pemasangan cincin, tanda tangan buku nikah, sungkeman',
                'Menyiapkan buku tamu & area tanda tangan',
                'Foto keluarga besar setelah akad',
            ]],
            ['title' => 'Perlengkapan Prosesi', 'icon' => 'checklist', 'tasks' => [
                'Buku nikah (disiapkan penghulu/KUA)',
                "Sajadah & Al-Qur'an untuk prosesi",
                'Baki/nampan untuk mahar & cincin',
                'Kain untuk sungkeman',
                'Sound system & mic untuk ijab kabul',
                'Souvenir untuk tamu akad',
                'Amplop untuk penghulu & saksi (uang terima kasih)',
            ]],
            ['title' => 'Ceklis Hari-H', 'icon' => 'checkmark.circle', 'tasks' => [
                'Konfirmasi ulang kehadiran penghulu & saksi (H-1)',
                'Konfirmasi ulang semua vendor (H-1)',
                'Siapkan semua dokumen asli dalam satu map',
                'Mandi & bersiap lebih awal (mempelai)',
                'Makeup & busana selesai sebelum jam akad',
                'Cek kelengkapan mahar, cincin, & seserahan',
                'Tes sound system & mic',
                'Briefing keluarga tentang alur acara',
                'Prosesi ijab kabul',
                'Penyerahan mahar & pemasangan cincin',
                'Penandatanganan buku nikah oleh mempelai, wali, saksi, penghulu',
                'Doa & nasihat pernikahan',
                'Sungkeman kepada orang tua',
                'Sesi foto bersama',
                'Serah terima buku nikah',
            ]],
        ];
    }

    /**
     * @return array<int, array{title: string, icon: string, tasks: array<int, string>}>
     */
    private function resepsi(): array
    {
        return [
            ['title' => 'Perencanaan Awal', 'icon' => 'calendar', 'tasks' => [
                'Menentukan tanggal & jam resepsi',
                'Menentukan konsep/tema resepsi',
                'Menyusun anggaran (budget) resepsi',
                'Memperkirakan jumlah tamu undangan',
                'Menentukan indoor/outdoor',
                'Membuat timeline persiapan',
            ]],
            ['title' => 'Venue / Tempat', 'icon' => 'building.2', 'tasks' => [
                'Survei beberapa pilihan gedung/tempat',
                'Booking venue & bayar DP',
                'Cek kapasitas & fasilitas (parkir, toilet, listrik, AC)',
                'Cek jadwal & durasi sewa',
                'Menyiapkan rencana cadangan cuaca (outdoor)',
                'Koordinasi aturan & perizinan venue',
            ]],
            ['title' => 'Vendor Utama', 'icon' => 'person.3', 'tasks' => [
                'Booking Wedding Organizer (WO) / koordinator',
                'Booking katering & jadwal food tasting',
                'Booking vendor dekorasi & pelaminan',
                'Booking fotografer & videografer',
                'Booking MUA (perias) & hairdo',
                'Booking hiburan (musik/band/MC)',
                'Booking vendor busana/wedding gown & jas',
            ]],
            ['title' => 'Undangan', 'icon' => 'envelope', 'tasks' => [
                'Menyusun daftar tamu final',
                'Desain undangan (cetak & digital)',
                'Cetak undangan fisik',
                'Membuat undangan digital & peta lokasi',
                'Menyebar undangan (H-3 sampai H-2 minggu)',
                'Menyiapkan RSVP / konfirmasi kehadiran',
                'Menyiapkan buku tamu & meja penerima tamu',
            ]],
            ['title' => 'Busana & Beauty', 'icon' => 'tshirt', 'tasks' => [
                'Fitting gaun/busana pengantin wanita',
                'Fitting jas/busana pengantin pria',
                'Menyiapkan busana orang tua & keluarga inti',
                'Menyiapkan seragam panitia/among tamu',
                'Jadwal makeup & hairdo hari-H',
                'Perawatan tubuh/spa menjelang hari-H',
                'Menyiapkan sepatu & aksesori',
            ]],
            ['title' => 'Dekorasi & Tata Panggung', 'icon' => 'sparkles', 'tasks' => [
                'Finalisasi konsep dekorasi & pelaminan',
                'Menentukan rangkaian & jenis bunga',
                'Dekorasi meja tamu & area foto (photobooth)',
                'Menyiapkan welcome board & signage',
                'Tata pencahayaan & panggung',
                'Menyiapkan area VIP/keluarga',
            ]],
            ['title' => 'Konsumsi', 'icon' => 'fork.knife', 'tasks' => [
                'Finalisasi menu katering',
                'Menentukan jumlah pax & stall/buffet',
                'Menyiapkan menu khusus (VIP, anak, vegetarian)',
                'Menyiapkan kue pengantin (wedding cake)',
                'Menyiapkan minuman & dessert corner',
                'Menyiapkan konsumsi vendor & panitia',
            ]],
            ['title' => 'Hiburan & Acara', 'icon' => 'music.note', 'tasks' => [
                'Finalisasi susunan acara (rundown) dengan MC & WO',
                'Menyiapkan playlist/lagu (termasuk lagu spesial)',
                'Koordinasi pengisi hiburan (band/organ tunggal)',
                'Menyiapkan prosesi khusus (tumpeng, potong kue, lempar bunga)',
                'Menyiapkan tari/prosesi adat (jika ada)',
                'Tes sound system & mic',
            ]],
            ['title' => 'Souvenir & Perlengkapan', 'icon' => 'gift', 'tasks' => [
                'Menyiapkan souvenir tamu',
                'Menyiapkan kotak angpau & petugas penjaga',
                'Menyiapkan meja seserahan/mahar untuk dipajang',
                'Menyiapkan seragam & tanda pengenal panitia',
                'Menyiapkan perlengkapan P3K & darurat',
            ]],
            ['title' => 'Logistik & Transportasi', 'icon' => 'car', 'tasks' => [
                'Menyiapkan transportasi mempelai (mobil pengantin)',
                'Koordinasi parkir & petugas parkir',
                'Menyiapkan akomodasi tamu luar kota (jika ada)',
                'Menyiapkan ruang transit/rias pengantin',
                'Koordinasi bongkar-pasang dekorasi dengan venue',
            ]],
            ['title' => 'Susunan Acara', 'icon' => 'list.bullet.rectangle', 'tasks' => [
                'Kedatangan & standby mempelai',
                'Penerimaan tamu (among tamu siap)',
                'Pembukaan oleh MC',
                'Prosesi masuk pengantin',
                'Sambutan keluarga',
                'Potong kue & tumpeng',
                'Toast/doa bersama',
                'Hiburan & ramah tamah',
                'Sesi foto bersama tamu',
                'Penutup',
            ]],
            ['title' => 'Ceklis Hari-H', 'icon' => 'checkmark.circle', 'tasks' => [
                'Konfirmasi ulang semua vendor (H-1)',
                'Cek kelengkapan busana, souvenir, kotak angpau',
                'Makeup & busana selesai sebelum acara',
                'Venue & dekorasi selesai dipasang',
                'Tes sound, musik, & pencahayaan',
                'Briefing panitia & among tamu',
                'Konsumsi & katering siap',
                'Dokumentasi standby',
                'Acara berjalan sesuai rundown',
                'Serah terima angpau & barang berharga ke keluarga',
                'Beres-beres & pengembalian perlengkapan sewa',
            ]],
        ];
    }
}
