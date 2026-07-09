<?php

namespace App\Http\Controllers;

use App\Models\CustomerPreparationTaskAttachment;
use App\Support\DocumentFolder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\View\View;

class DokumenController extends Controller
{
    private const STORAGE_QUOTA_GB = 5;

    public function index(Request $request): View
    {
        $user = $request->user();
        $info = $user->weddingInfo;
        $events = $user->weddingEvents()->get();
        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->filter(fn ($event) => $event->tgl_acara?->isFuture())->sortBy('tgl_acara')->first()
            ?? $events->sortByDesc('tgl_acara')->first();

        $search = trim($request->string('q')->toString());
        $folder = $request->string('folder', DocumentFolder::All)->toString();
        $sort = $request->string('sort', 'latest')->toString();
        $perPage = max(4, min($request->integer('per_page', 8), 20));

        if (! in_array($folder, DocumentFolder::selectableFolders(), true)) {
            $folder = DocumentFolder::All;
        }

        $documents = $this->buildDocuments($user->id, $info);
        $folderCounts = $this->folderCounts($documents);

        $filtered = $documents
            ->when($folder !== DocumentFolder::All, fn (Collection $items) => $items->where('folder', $folder))
            ->when($search !== '', function (Collection $items) use ($search): Collection {
                $query = strtolower($search);

                return $items->filter(fn (array $document): bool => str_contains(strtolower($document['file_name']), $query)
                    || str_contains(strtolower($document['description']), $query)
                    || str_contains(strtolower($document['uploaded_by']), $query));
            })
            ->values();

        $sorted = match ($sort) {
            'oldest' => $filtered->sortBy('uploaded_at'),
            'name' => $filtered->sortBy('file_name'),
            default => $filtered->sortByDesc('uploaded_at'),
        };

        $page = max($request->integer('page', 1), 1);
        $paginated = $this->paginateCollection($sorted->values(), $perPage, $page, $request);

        $usedBytes = (int) $documents->sum('file_size');
        $quotaBytes = self::STORAGE_QUOTA_GB * 1024 * 1024 * 1024;
        $usedPercent = $quotaBytes > 0 ? (int) min(100, round(($usedBytes / $quotaBytes) * 100)) : 0;

        $recentUploads = $documents->sortByDesc('uploaded_at')->take(4)->values();

        return view('dokumen.index', [
            'coupleLabel' => $this->coupleLabel($info, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d F Y'),
            'unreadNotifications' => $user->customerNotifications()->where('is_unread', true)->count(),
            'search' => $search,
            'folder' => $folder,
            'sort' => $sort,
            'perPage' => $perPage,
            'documents' => $paginated,
            'folderCounts' => $folderCounts,
            'recentUploads' => $recentUploads,
            'storage' => [
                'quota_gb' => self::STORAGE_QUOTA_GB,
                'used_bytes' => $usedBytes,
                'used_gb' => round($usedBytes / (1024 * 1024 * 1024), 1),
                'available_gb' => max(round((max($quotaBytes - $usedBytes, 0)) / (1024 * 1024 * 1024), 1), 0),
                'used_percent' => $usedPercent,
            ],
        ]);
    }

    /**
     * @return array{label: string, color: string, bg: string}
     */
    public static function fileBadge(string $fileName, ?string $mimeType = null): array
    {
        $extension = strtoupper(pathinfo($fileName, PATHINFO_EXTENSION));

        if ($extension === '' && $mimeType) {
            $extension = match (true) {
                str_contains($mimeType, 'pdf') => 'PDF',
                str_contains($mimeType, 'png') => 'PNG',
                str_contains($mimeType, 'jpeg'), str_contains($mimeType, 'jpg') => 'JPG',
                str_contains($mimeType, 'sheet'), str_contains($mimeType, 'excel') => 'XLS',
                default => 'DOC',
            };
        }

        return match ($extension) {
            'PDF' => ['label' => 'PDF', 'color' => 'text-rose-600', 'bg' => 'bg-rose-50'],
            'JPG', 'JPEG' => ['label' => 'JPG', 'color' => 'text-sage-700', 'bg' => 'bg-sage-50'],
            'PNG' => ['label' => 'PNG', 'color' => 'text-amber-600', 'bg' => 'bg-amber-50'],
            'XLS', 'XLSX', 'CSV' => ['label' => $extension === 'CSV' ? 'CSV' : 'XLS', 'color' => 'text-violet-600', 'bg' => 'bg-violet-50'],
            'DOC', 'DOCX' => ['label' => 'DOC', 'color' => 'text-sky-600', 'bg' => 'bg-sky-50'],
            default => ['label' => $extension !== '' ? $extension : 'DOC', 'color' => 'text-gray-600', 'bg' => 'bg-gray-50'],
        };
    }

    public static function formatFileSize(int $bytes): string
    {
        if ($bytes >= 1_048_576) {
            return number_format($bytes / 1_048_576, 1, ',', '.').' MB';
        }

        if ($bytes >= 1024) {
            return number_format($bytes / 1024, 0, ',', '.').' KB';
        }

        return $bytes.' B';
    }

    /**
     * @return Collection<int, array{
     *     id: string|int,
     *     file_name: string,
     *     description: string,
     *     folder: string,
     *     uploaded_by: string,
     *     uploaded_at: Carbon,
     *     file_size: int,
     *     mime_type: ?string,
     *     url: ?string,
     *     is_dummy: bool
     * }>
     */
    private function buildDocuments(int $userId, ?object $weddingInfo): Collection
    {
        $attachments = CustomerPreparationTaskAttachment::query()
            ->where('user_id', $userId)
            ->with('preparationTask:id,title')
            ->latest()
            ->get();

        $groomName = $weddingInfo?->groom_name;
        $brideName = $weddingInfo?->bride_name;

        $documents = $attachments->map(function (CustomerPreparationTaskAttachment $attachment) use ($groomName, $brideName): array {
            $taskTitle = $attachment->preparationTask?->title ?? 'Persiapan pernikahan';

            return [
                'id' => $attachment->id,
                'file_name' => $attachment->file_name,
                'description' => $taskTitle,
                'folder' => DocumentFolder::match($taskTitle, $attachment->file_name),
                'uploaded_by' => $this->uploadedByLabel($attachment->id, $groomName, $brideName),
                'uploaded_at' => $attachment->created_at ?? now(),
                'file_size' => (int) $attachment->file_size,
                'mime_type' => $attachment->mime_type,
                'url' => $attachment->url,
                'is_dummy' => false,
            ];
        });

        if ($documents->isNotEmpty()) {
            return $documents;
        }

        return $this->dummyDocuments($groomName, $brideName);
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $documents
     * @return array<string, int>
     */
    private function folderCounts(Collection $documents): array
    {
        $counts = [DocumentFolder::All => $documents->count()];

        foreach (DocumentFolder::selectableFolders() as $folder) {
            if ($folder === DocumentFolder::All) {
                continue;
            }

            $counts[$folder] = $documents->where('folder', $folder)->count();
        }

        return $counts;
    }

    /**
     * @return Collection<int, array{
     *     id: string,
     *     file_name: string,
     *     description: string,
     *     folder: string,
     *     uploaded_by: string,
     *     uploaded_at: Carbon,
     *     file_size: int,
     *     mime_type: ?string,
     *     url: ?string,
     *     is_dummy: bool
     * }>
     */
    private function dummyDocuments(?string $groomName, ?string $brideName): Collection
    {
        $groom = $groomName ?: 'Rama';
        $bride = $brideName ?: 'Anya';

        $samples = [
            ['file_name' => 'Kontrak_Venue_Aston.pdf', 'description' => 'Perjanjian sewa venue akad & resepsi', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $groom, 'days_ago' => 1, 'size' => 2_516_582],
            ['file_name' => 'Invoice_Katering_Termin2.pdf', 'description' => 'Invoice pembayaran kedua katering', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $bride, 'days_ago' => 2, 'size' => 1_843_200],
            ['file_name' => 'Mockup_Undangan_Digital.jpg', 'description' => 'Desain undangan digital versi final', 'folder' => DocumentFolder::Design, 'uploaded_by' => $bride, 'days_ago' => 3, 'size' => 3_145_728],
            ['file_name' => 'Surat_Keterangan_KUA.pdf', 'description' => 'Berkas pendaftaran nikah ke KUA', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $groom, 'days_ago' => 4, 'size' => 1_258_291],
            ['file_name' => 'Rincian_Budget_2026.xlsx', 'description' => 'Rincian anggaran pernikahan terbaru', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $groom, 'days_ago' => 5, 'size' => 892_416],
            ['file_name' => 'Kontrak_WO_Makna.pdf', 'description' => 'Kontrak wedding organizer lengkap', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $bride, 'days_ago' => 6, 'size' => 2_097_152],
            ['file_name' => 'Layout_Meja_Tamu.pdf', 'description' => 'Layout penempatan meja tamu resepsi', 'folder' => DocumentFolder::Design, 'uploaded_by' => $groom, 'days_ago' => 7, 'size' => 1_572_864],
            ['file_name' => 'Fotokopi_KTP_Mempelai.pdf', 'description' => 'Salinan KTP kedua mempelai', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $bride, 'days_ago' => 8, 'size' => 734_003],
            ['file_name' => 'Proposal_Dekorasi_Bloom.pdf', 'description' => 'Proposal dekorasi akad & resepsi', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $groom, 'days_ago' => 9, 'size' => 2_234_112],
            ['file_name' => 'Daftar_Pembayaran_Vendor.xlsx', 'description' => 'Tracking pembayaran vendor', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $bride, 'days_ago' => 10, 'size' => 655_360],
            ['file_name' => 'Souvenir_Design_Final.png', 'description' => 'Desain souvenir tamu resepsi', 'folder' => DocumentFolder::Design, 'uploaded_by' => $bride, 'days_ago' => 11, 'size' => 1_884_736],
            ['file_name' => 'Surat_Rekomendasi_Nikah.pdf', 'description' => 'Surat rekomendasi dari kelurahan', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $groom, 'days_ago' => 12, 'size' => 1_126_400],
            ['file_name' => 'Kontrak_Fotografi_Luminous.pdf', 'description' => 'Kontrak jasa foto & video', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $bride, 'days_ago' => 13, 'size' => 1_990_656],
            ['file_name' => 'Termin_Catering_Q1.pdf', 'description' => 'Bukti transfer termin catering', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $groom, 'days_ago' => 14, 'size' => 942_080],
            ['file_name' => 'Save_The_Date_Design.jpg', 'description' => 'Desain save the date digital', 'folder' => DocumentFolder::Design, 'uploaded_by' => $bride, 'days_ago' => 15, 'size' => 2_621_440],
            ['file_name' => 'Akta_Kelahiran_Salinan.pdf', 'description' => 'Salinan akta kelahiran mempelai', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $groom, 'days_ago' => 16, 'size' => 1_441_792],
            ['file_name' => 'Kontrak_MUA_Glow.pdf', 'description' => 'Kontrak makeup artist hari H', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $bride, 'days_ago' => 17, 'size' => 1_703_936],
            ['file_name' => 'Anggaran_Dekorasi.xlsx', 'description' => 'Breakdown biaya dekorasi', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $groom, 'days_ago' => 18, 'size' => 786_432],
            ['file_name' => 'Moodboard_Resepsi.pdf', 'description' => 'Referensi dekorasi resepsi', 'folder' => DocumentFolder::Design, 'uploaded_by' => $bride, 'days_ago' => 19, 'size' => 3_670_016],
            ['file_name' => 'Surat_Izin_Orang_Tua.docx', 'description' => 'Surat izin menikah dari orang tua', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $groom, 'days_ago' => 20, 'size' => 524_288],
            ['file_name' => 'Addendum_Kontrak_Venue.pdf', 'description' => 'Addendum perubahan jam acara', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $bride, 'days_ago' => 21, 'size' => 1_310_720],
            ['file_name' => 'Rekap_Transfer_Vendor.xlsx', 'description' => 'Rekap transfer ke vendor', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $groom, 'days_ago' => 22, 'size' => 917_504],
            ['file_name' => 'Kartu_Ucapan_Design.ai', 'description' => 'File desain kartu ucapan', 'folder' => DocumentFolder::Design, 'uploaded_by' => $bride, 'days_ago' => 23, 'size' => 4_194_304],
            ['file_name' => 'Buku_Nikah_Fotokopi.pdf', 'description' => 'Fotokopi buku nikah orang tua', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $groom, 'days_ago' => 24, 'size' => 1_048_576],
            ['file_name' => 'Proposal_Catering_Sajian.pdf', 'description' => 'Menu dan proposal catering', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $bride, 'days_ago' => 25, 'size' => 2_359_296],
            ['file_name' => 'Cashflow_Pernikahan.xlsx', 'description' => 'Arus kas persiapan pernikahan', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $groom, 'days_ago' => 26, 'size' => 1_179_648],
            ['file_name' => 'Backdrop_Akad_Mockup.jpg', 'description' => 'Mockup backdrop akad nikah', 'folder' => DocumentFolder::Design, 'uploaded_by' => $bride, 'days_ago' => 27, 'size' => 2_883_584],
            ['file_name' => 'Surat_Keterangan_Belum_Menikah.pdf', 'description' => 'SKBM dari kelurahan', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $groom, 'days_ago' => 28, 'size' => 1_363_148],
            ['file_name' => 'Kontrak_Sound_System.pdf', 'description' => 'Kontrak sound system resepsi', 'folder' => DocumentFolder::Vendor, 'uploaded_by' => $bride, 'days_ago' => 29, 'size' => 1_835_008],
            ['file_name' => 'Nota_Pembelian_Aksesoris.pdf', 'description' => 'Nota pembelian aksesoris pengantin', 'folder' => DocumentFolder::Finance, 'uploaded_by' => $groom, 'days_ago' => 30, 'size' => 688_128],
            ['file_name' => 'Timeline_Rundown_Resepsi.docx', 'description' => 'Rundown acara resepsi', 'folder' => DocumentFolder::Design, 'uploaded_by' => $bride, 'days_ago' => 31, 'size' => 458_752],
            ['file_name' => 'Pernyataan_Keabsahan_Data.pdf', 'description' => 'Surat pernyataan data pernikahan', 'folder' => DocumentFolder::Legal, 'uploaded_by' => $groom, 'days_ago' => 32, 'size' => 1_015_808],
        ];

        return collect($samples)->values()->map(function (array $sample, int $index): array {
            return [
                'id' => "dummy-{$index}",
                'file_name' => $sample['file_name'],
                'description' => $sample['description'],
                'folder' => $sample['folder'],
                'uploaded_by' => $sample['uploaded_by'],
                'uploaded_at' => now()->subDays($sample['days_ago'])->setTime(10, 30),
                'file_size' => $sample['size'],
                'mime_type' => null,
                'url' => null,
                'is_dummy' => true,
            ];
        });
    }

    private function uploadedByLabel(int|string $id, ?string $groomName, ?string $brideName): string
    {
        if ($groomName && $brideName) {
            return is_numeric($id) && ((int) $id % 2 === 0) ? $groomName : $brideName;
        }

        return $groomName ?: ($brideName ?: 'Anda');
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $items
     */
    private function paginateCollection(Collection $items, int $perPage, int $page, Request $request): LengthAwarePaginator
    {
        $total = $items->count();
        $results = $items->slice(($page - 1) * $perPage, $perPage)->values();

        return new LengthAwarePaginator(
            $results,
            $total,
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
