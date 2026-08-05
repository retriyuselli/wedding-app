<?php

namespace Database\Seeders;

use App\Models\DocumentFolder;
use App\Models\User;
use App\Models\WeddingDocument;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;

class WeddingDocumentSeeder extends Seeder
{
    /**
     * @var list<array{file_name: string, category: string, folder: string, body: string}>
     */
    private const DOCUMENTS = [
        [
            'file_name' => 'Kontrak_Venue.txt',
            'category' => 'vendor',
            'folder' => 'Kontrak Vendor',
            'body' => "Kontrak sewa venue akad & resepsi (sample seed).\n",
        ],
        [
            'file_name' => 'Invoice_Catering_Termin1.txt',
            'category' => 'keuangan',
            'folder' => 'Keuangan',
            'body' => "Invoice katering termin 1 — sample seed.\n",
        ],
        [
            'file_name' => 'Surat_Keterangan_KUA.txt',
            'category' => 'akad',
            'folder' => 'Dokumen Resmi',
            'body' => "Berkas pendaftaran nikah KUA — sample seed.\n",
        ],
        [
            'file_name' => 'Mockup_Undangan.txt',
            'category' => 'resepsi',
            'folder' => 'Desain & Undangan',
            'body' => "Catatan desain undangan digital — sample seed.\n",
        ],
        [
            'file_name' => 'Rincian_Budget.txt',
            'category' => 'keuangan',
            'folder' => 'Keuangan',
            'body' => "Ringkasan anggaran pernikahan — sample seed.\n",
        ],
    ];

    public function run(): void
    {
        User::query()->each(function (User $user): void {
            $folders = DocumentFolder::query()
                ->where('user_id', $user->id)
                ->get()
                ->keyBy('name');

            foreach (self::DOCUMENTS as $document) {
                $folder = $folders->get($document['folder']);
                $relativePath = sprintf(
                    'wedding-documents/%d/%s',
                    $user->id,
                    $document['file_name'],
                );

                Storage::disk('public')->put($relativePath, $document['body']);

                WeddingDocument::query()->updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'file_name' => $document['file_name'],
                    ],
                    [
                        'document_folder_id' => $folder?->id,
                        'file_path' => $relativePath,
                        'file_size' => strlen($document['body']),
                        'mime_type' => 'text/plain',
                        'category' => $document['category'],
                    ],
                );
            }
        });
    }
}
