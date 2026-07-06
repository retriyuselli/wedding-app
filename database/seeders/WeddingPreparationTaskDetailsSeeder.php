<?php

namespace Database\Seeders;

use App\Models\CustomerPreparationSubTask;
use App\Models\CustomerPreparationTask;
use App\Models\CustomerPreparationTaskAttachment;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class WeddingPreparationTaskDetailsSeeder extends Seeder
{
    /**
     * Mengisi detail semua task persiapan:
     * 1. Auto-enrich untuk seluruh task (deskripsi, prioritas, sub tugas, lampiran dokumen).
     * 2. Manual override untuk task-task penting dengan data lebih kaya.
     */
    public function run(): void
    {
        $manualDetails = $this->manualDetails();

        User::all()->each(function (User $user) use ($manualDetails): void {
            $manualTitles = array_keys($manualDetails);

            CustomerPreparationTask::query()
                ->where('user_id', $user->id)
                ->with('section')
                ->orderBy('id')
                ->each(function (CustomerPreparationTask $task) use ($user, $manualTitles): void {
                    if (in_array($task->title, $manualTitles, true)) {
                        return;
                    }

                    $this->applyAutoDetail($user->id, $task);
                });

            foreach ($manualDetails as $title => $detail) {
                $task = CustomerPreparationTask::query()
                    ->where('user_id', $user->id)
                    ->where('title', $title)
                    ->first();

                if (! $task instanceof CustomerPreparationTask) {
                    continue;
                }

                $this->applyManualDetail($user->id, $task, $detail);
            }
        });
    }

    private function applyAutoDetail(int $userId, CustomerPreparationTask $task): void
    {
        $sectionTitle = $task->section?->title ?? 'Persiapan';

        $task->update([
            'description' => "Langkah persiapan dalam kategori \"{$sectionTitle}\": {$task->title}.",
            'priority'    => $this->resolvePriority($sectionTitle, $task->title),
            'notes'       => $this->resolveAutoNotes($sectionTitle),
        ]);

        $sortOrder = 1;

        foreach ($this->generateSubTasks($task->title, $sectionTitle) as $subTitle) {
            CustomerPreparationSubTask::create([
                'user_id'             => $userId,
                'preparation_task_id' => $task->id,
                'title'               => $subTitle,
                'status'              => 'pending',
                'sort_order'          => $sortOrder++,
            ]);
        }

        if ($this->shouldHaveAttachment($task->title)) {
            $this->createAttachment($userId, $task->id, [
                'name' => $this->attachmentFileName($task->title),
            ]);
        }
    }

    /**
     * @param  array{
     *     description?: string,
     *     notes?: string,
     *     priority?: string,
     *     status?: string,
     *     due_date?: string,
     *     sub_tasks?: array<int, array{title: string, status?: string, due_date?: string, completed_at?: string}>,
     *     attachments?: array<int, array{name: string, uploaded_at?: string}>
     * }  $detail
     */
    private function applyManualDetail(int $userId, CustomerPreparationTask $task, array $detail): void
    {
        $task->subTasks()->delete();
        $task->attachments()->each(function (CustomerPreparationTaskAttachment $attachment): void {
            Storage::disk('public')->delete($attachment->file_path);
            $attachment->delete();
        });

        $task->update([
            'description' => $detail['description'] ?? null,
            'notes'       => $detail['notes'] ?? null,
            'priority'    => $detail['priority'] ?? 'medium',
            'status'      => $detail['status'] ?? $task->status,
            'due_date'    => $detail['due_date'] ?? $task->due_date,
        ]);

        $sortOrder = 1;

        foreach ($detail['sub_tasks'] ?? [] as $subTask) {
            CustomerPreparationSubTask::create([
                'user_id'             => $userId,
                'preparation_task_id' => $task->id,
                'title'               => $subTask['title'],
                'status'              => $subTask['status'] ?? 'pending',
                'due_date'            => $subTask['due_date'] ?? null,
                'completed_at'        => $subTask['completed_at'] ?? null,
                'sort_order'          => $sortOrder++,
            ]);
        }

        foreach ($detail['attachments'] ?? [] as $attachment) {
            $this->createAttachment($userId, $task->id, $attachment);
        }
    }

    private function resolvePriority(string $sectionTitle, string $taskTitle): string
    {
        $haystack = Str::lower($sectionTitle.' '.$taskTitle);

        if (Str::contains($haystack, ['hari-h', 'ceklis', 'administrasi', 'dokumen', 'perencanaan awal', 'vendor utama', 'penghulu', 'venue', 'undangan', 'kua', 'berkas', 'surat'])) {
            return 'high';
        }

        if (Str::contains($haystack, ['susunan acara', 'ramah tamah', 'pembukaan', 'penutup', 'prosesi'])) {
            return 'low';
        }

        if (Str::contains($haystack, ['booking', 'mengurus', 'mendaftarkan', 'menyusun daftar', 'finalisasi', 'konfirmasi'])) {
            return 'medium';
        }

        return 'medium';
    }

    private function resolveAutoNotes(string $sectionTitle): ?string
    {
        if (Str::contains(Str::lower($sectionTitle), ['hari-h', 'administrasi', 'vendor', 'venue'])) {
            return 'Koordinasikan dengan keluarga inti dan catat progres di aplikasi.';
        }

        return null;
    }

    /**
     * @return array<int, string>
     */
    private function generateSubTasks(string $title, string $sectionTitle): array
    {
        if (Str::contains(Str::lower($sectionTitle), 'susunan acara')) {
            return [
                'Briefing petugas terkait',
                'Pastikan siap pada hari H',
            ];
        }

        $lower = Str::lower($title);

        if (Str::startsWith($lower, ['menentukan', 'menyepakati'])) {
            return ['Kumpulkan opsi & referensi', 'Diskusi dengan pihak terkait', 'Kunci keputusan'];
        }

        if (Str::startsWith($lower, ['mengurus', 'melengkapi', 'mendaftarkan'])) {
            return ['Siapkan dokumen/kebutuhan', 'Proses ke instansi/pihak terkait', 'Simpan salinan & update status'];
        }

        if (Str::startsWith($lower, 'booking')) {
            return ['Riset & bandingkan vendor', 'Negosiasi harga & paket', 'Bayar DP & kunci jadwal'];
        }

        if (Str::startsWith($lower, ['menyiapkan', 'membeli', 'menyediakan'])) {
            return ['Buat daftar kebutuhan', 'Beli / sewa perlengkapan', 'Cek kelengkapan'];
        }

        if (Str::startsWith($lower, 'fotokopi')) {
            return ['Siapkan dokumen asli', 'Fotokopi sesuai jumlah', 'Masukkan ke map berkas'];
        }

        if (Str::startsWith($lower, ['konfirmasi', 'cek', 'tes', 'brief'])) {
            return ['Buat checklist singkat', 'Konfirmasi ke pihak terkait', 'Update status di aplikasi'];
        }

        if (Str::startsWith($lower, ['menyusun', 'membuat'])) {
            return ['Kumpulkan data awal', 'Susun draft', 'Review & finalisasi'];
        }

        if (Str::startsWith($lower, ['mengundang', 'menyebar'])) {
            return ['Siapkan daftar penerima', 'Kirim undangan', 'Konfirmasi kehadiran'];
        }

        return ['Rencanakan langkah awal', 'Laksanakan persiapan', 'Verifikasi selesai'];
    }

    private function shouldHaveAttachment(string $title): bool
    {
        return Str::contains(Str::lower($title), [
            'dokumen', 'surat', 'berkas', 'fotokopi', 'daftar tamu', 'kontrak',
            'undangan', 'n1', 'n4', 'kua', 'map', 'buku nikah', 'ijazah',
        ]);
    }

    private function attachmentFileName(string $title): string
    {
        $slug = Str::slug(Str::limit($title, 40, ''));

        return Str::upper($slug).'.pdf';
    }

    /**
     * @param  array{name: string, uploaded_at?: string}  $attachment
     */
    private function createAttachment(int $userId, int $taskId, array $attachment): void
    {
        $slug = str($attachment['name'])->lower()->replace(' ', '-')->value();
        $filePath = "preparation-attachments/{$taskId}-{$slug}";
        $content = $this->samplePdfContent($attachment['name']);

        Storage::disk('public')->put($filePath, $content);

        CustomerPreparationTaskAttachment::create([
            'user_id'             => $userId,
            'preparation_task_id' => $taskId,
            'file_name'           => $attachment['name'],
            'file_path'           => $filePath,
            'file_size'           => strlen($content),
            'mime_type'           => 'application/pdf',
            'created_at'          => $attachment['uploaded_at'] ?? now(),
            'updated_at'          => $attachment['uploaded_at'] ?? now(),
        ]);
    }

    /**
     * @return array<string, array{
     *     description?: string,
     *     notes?: string,
     *     priority?: string,
     *     status?: string,
     *     due_date?: string,
     *     sub_tasks?: array<int, array{title: string, status?: string, due_date?: string, completed_at?: string}>,
     *     attachments?: array<int, array{name: string, uploaded_at?: string}>
     * }>
     */
    private function manualDetails(): array
    {
        return [
            'Menentukan tanggal dan jam akad' => [
                'description' => 'Menentukan tanggal terbaik untuk pelaksanaan akad nikah bersama keluarga inti dan penghulu.',
                'notes'       => "Tanggal pilihan utama: 12 Feb 2026 (Kamis)\nTanggal cadangan: 19 Feb 2026 (Kamis)",
                'priority'    => 'high',
                'status'      => 'done',
                'due_date'    => '2026-02-12',
                'sub_tasks'   => [
                    ['title' => 'Diskusi dengan pasangan', 'status' => 'done', 'completed_at' => '2026-01-10'],
                    ['title' => 'Cek ketersediaan penghulu', 'status' => 'done', 'completed_at' => '2026-01-15'],
                    ['title' => 'Konsultasi dengan orang tua', 'status' => 'done', 'completed_at' => '2026-01-18'],
                    ['title' => 'Pilih tanggal cadangan', 'status' => 'in_progress', 'due_date' => '2026-01-20'],
                    ['title' => 'Konfirmasi tanggal dan simpan', 'status' => 'pending'],
                ],
                'attachments' => [
                    ['name' => 'Daftar_Ketersediaan_Penghulu.pdf', 'uploaded_at' => '2026-01-15 10:00:00'],
                ],
            ],
            'Mendaftarkan pernikahan ke KUA (minimal H-10 hari kerja)' => [
                'description' => 'Mendaftarkan rencana pernikahan ke KUA setempat beserta seluruh berkas persyaratan.',
                'notes'       => "Bawa semua dokumen asli + fotokopi.\nDatang pagi agar tidak antre.",
                'priority'    => 'high',
                'status'      => 'in_progress',
                'due_date'    => '2026-02-02',
                'sub_tasks'   => [
                    ['title' => 'Kumpulkan berkas N1-N4', 'status' => 'done', 'completed_at' => '2026-01-22'],
                    ['title' => 'Fotokopi KTP, KK, akta kelahiran', 'status' => 'done', 'completed_at' => '2026-01-23'],
                    ['title' => 'Siapkan pas foto latar biru', 'status' => 'in_progress', 'due_date' => '2026-01-28'],
                    ['title' => 'Datang ke KUA untuk daftar', 'status' => 'pending', 'due_date' => '2026-02-02'],
                ],
                'attachments' => [
                    ['name' => 'Checklist_Berkas_KUA.pdf', 'uploaded_at' => '2026-01-22 09:00:00'],
                ],
            ],
            'Menyepakati bentuk mahar (uang tunai, emas, seperangkat alat salat, dll)' => [
                'description' => 'Menyepakati bentuk dan nilai mahar yang akan diberikan saat akad.',
                'notes'       => 'Disepakati: seperangkat alat salat + emas 5 gram + uang tunai sesuai tanggal akad.',
                'priority'    => 'medium',
                'status'      => 'in_progress',
                'due_date'    => '2026-01-30',
                'sub_tasks'   => [
                    ['title' => 'Diskusi bentuk mahar dengan pasangan', 'status' => 'done', 'completed_at' => '2026-01-12'],
                    ['title' => 'Tentukan nominal & jenis emas', 'status' => 'in_progress', 'due_date' => '2026-01-25'],
                    ['title' => 'Beli perlengkapan mahar', 'status' => 'pending', 'due_date' => '2026-01-30'],
                ],
            ],
            'Booking MUA (Make Up Artist) untuk akad' => [
                'description' => 'Memilih dan memesan jasa perias untuk hari akad.',
                'priority'    => 'medium',
                'due_date'    => '2026-01-31',
                'sub_tasks'   => [
                    ['title' => 'Riset & bandingkan portofolio MUA', 'status' => 'done', 'completed_at' => '2026-01-14'],
                    ['title' => 'Trial makeup', 'status' => 'pending', 'due_date' => '2026-01-28'],
                    ['title' => 'Bayar DP & kunci jadwal', 'status' => 'pending', 'due_date' => '2026-01-31'],
                ],
            ],
            'Menentukan tanggal & jam acara lamaran' => [
                'description' => 'Menyepakati tanggal dan jam pelaksanaan acara lamaran bersama kedua keluarga.',
                'notes'       => 'Diusahakan akhir pekan agar keluarga besar bisa hadir.',
                'priority'    => 'high',
                'status'      => 'done',
                'due_date'    => '2025-12-14',
                'sub_tasks'   => [
                    ['title' => 'Diskusi dengan keluarga pihak wanita', 'status' => 'done', 'completed_at' => '2025-11-20'],
                    ['title' => 'Koordinasi dengan keluarga pihak pria', 'status' => 'done', 'completed_at' => '2025-11-25'],
                    ['title' => 'Kunci tanggal & umumkan ke keluarga', 'status' => 'done', 'completed_at' => '2025-11-28'],
                ],
            ],
            'Menentukan jumlah & jenis hantaran/seserahan' => [
                'description' => 'Menyusun daftar isi seserahan yang akan dibawa saat lamaran.',
                'notes'       => 'Jumlah hantaran ganjil sesuai adat: 7 kotak.',
                'priority'    => 'medium',
                'status'      => 'in_progress',
                'due_date'    => '2025-12-05',
                'sub_tasks'   => [
                    ['title' => 'Susun daftar isi seserahan', 'status' => 'done', 'completed_at' => '2025-11-22'],
                    ['title' => 'Belanja isi seserahan', 'status' => 'in_progress', 'due_date' => '2025-12-01'],
                    ['title' => 'Hias & tata seserahan', 'status' => 'pending', 'due_date' => '2025-12-05'],
                ],
            ],
            'Mengundang ustadz/penceramah' => [
                'description' => 'Mengundang ustadz untuk mengisi tausiyah pada acara pengajian.',
                'notes'       => 'Konfirmasi tema tausiyah: pernikahan dalam Islam.',
                'priority'    => 'high',
                'status'      => 'in_progress',
                'due_date'    => '2026-02-05',
                'sub_tasks'   => [
                    ['title' => 'Hubungi ustadz & cek jadwal', 'status' => 'done', 'completed_at' => '2026-01-16'],
                    ['title' => 'Sepakati honor & tema', 'status' => 'in_progress', 'due_date' => '2026-01-30'],
                    ['title' => 'Konfirmasi ulang H-3', 'status' => 'pending', 'due_date' => '2026-02-05'],
                ],
            ],
            'Menyusun rundown acara pengajian' => [
                'description' => 'Menyusun urutan acara pengajian dari pembukaan hingga penutup.',
                'priority'    => 'medium',
                'due_date'    => '2026-02-03',
                'sub_tasks'   => [
                    ['title' => 'Draft rundown', 'status' => 'in_progress', 'due_date' => '2026-01-29'],
                    ['title' => 'Koordinasi dengan MC', 'status' => 'pending', 'due_date' => '2026-02-03'],
                ],
            ],
            'Booking venue & bayar DP' => [
                'description' => 'Memesan gedung/tempat resepsi dan membayar uang muka untuk mengunci tanggal.',
                'notes'       => "DP 30% sudah dibayar.\nPelunasan H-14 sebelum acara.",
                'priority'    => 'high',
                'status'      => 'done',
                'due_date'    => '2025-12-20',
                'sub_tasks'   => [
                    ['title' => 'Survei 3 pilihan venue', 'status' => 'done', 'completed_at' => '2025-11-15'],
                    ['title' => 'Negosiasi harga & fasilitas', 'status' => 'done', 'completed_at' => '2025-11-30'],
                    ['title' => 'Tanda tangan kontrak & bayar DP', 'status' => 'done', 'completed_at' => '2025-12-05'],
                    ['title' => 'Jadwalkan pelunasan', 'status' => 'in_progress', 'due_date' => '2026-02-20'],
                ],
                'attachments' => [
                    ['name' => 'Kontrak_Sewa_Venue.pdf', 'uploaded_at' => '2025-12-05 14:00:00'],
                ],
            ],
            'Booking katering & jadwal food tasting' => [
                'description' => 'Memilih vendor katering dan menjadwalkan sesi cicip menu.',
                'notes'       => 'Estimasi 500 pax. Menu prasmanan + 5 stall.',
                'priority'    => 'high',
                'status'      => 'in_progress',
                'due_date'    => '2026-01-25',
                'sub_tasks'   => [
                    ['title' => 'Shortlist vendor katering', 'status' => 'done', 'completed_at' => '2025-12-10'],
                    ['title' => 'Food tasting', 'status' => 'in_progress', 'due_date' => '2026-01-18'],
                    ['title' => 'Finalisasi menu & jumlah pax', 'status' => 'pending', 'due_date' => '2026-01-25'],
                    ['title' => 'Bayar DP katering', 'status' => 'pending', 'due_date' => '2026-01-28'],
                ],
            ],
            'Menyusun daftar tamu final' => [
                'description' => 'Merapikan daftar tamu undangan resepsi untuk menentukan jumlah undangan cetak.',
                'notes'       => 'Target total tamu: 500 orang (250 dari masing-masing pihak).',
                'priority'    => 'medium',
                'status'      => 'in_progress',
                'due_date'    => '2026-01-15',
                'sub_tasks'   => [
                    ['title' => 'Kumpulkan daftar dari kedua keluarga', 'status' => 'done', 'completed_at' => '2025-12-20'],
                    ['title' => 'Hapus duplikat & rapikan', 'status' => 'in_progress', 'due_date' => '2026-01-10'],
                    ['title' => 'Tentukan jumlah undangan cetak', 'status' => 'pending', 'due_date' => '2026-01-15'],
                ],
            ],
            'Booking fotografer & videografer' => [
                'description' => 'Memesan tim dokumentasi foto dan video untuk resepsi.',
                'priority'    => 'medium',
                'due_date'    => '2026-01-20',
                'sub_tasks'   => [
                    ['title' => 'Bandingkan paket & portofolio', 'status' => 'done', 'completed_at' => '2025-12-18'],
                    ['title' => 'Pilih paket & bayar DP', 'status' => 'pending', 'due_date' => '2026-01-20'],
                ],
            ],
        ];
    }

    private function samplePdfContent(string $title): string
    {
        $safeTitle = str_replace(['(', ')'], ' ', $title);

        return <<<PDF
%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 300 144] /Contents 4 0 R >> endobj
4 0 obj << /Length 60 >> stream
BT /F1 12 Tf 40 100 Td ({$safeTitle}) Tj ET
endstream endobj
xref
0 5
0000000000 65535 f
0000000009 00000 n
0000000058 00000 n
0000000115 00000 n
0000000206 00000 n
trailer << /Size 5 /Root 1 0 R >>
startxref
320
%%EOF
PDF;
    }
}
