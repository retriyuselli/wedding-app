<?php

namespace App\Models;

use Database\Factories\WeddingDocumentFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class WeddingDocument extends Model
{
    /** @use HasFactory<WeddingDocumentFactory> */
    use HasFactory;

    public const STORAGE_QUOTA_BYTES = 5 * 1024 * 1024;

    public const MAX_UPLOAD_BYTES = 1 * 1024 * 1024;

    /**
     * @var array<string, string>
     */
    public static array $categoryOptions = [
        'akad' => 'Akad',
        'resepsi' => 'Resepsi',
        'vendor' => 'Vendor',
        'keuangan' => 'Keuangan',
    ];

    protected $fillable = [
        'user_id',
        'document_folder_id',
        'file_name',
        'file_path',
        'file_size',
        'mime_type',
        'category',
    ];

    protected function casts(): array
    {
        return [
            'file_size' => 'integer',
            'document_folder_id' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function folder(): BelongsTo
    {
        return $this->belongsTo(DocumentFolder::class, 'document_folder_id');
    }

    public function getUrlAttribute(): ?string
    {
        if ($this->file_path === '') {
            return null;
        }

        return Storage::disk('public')->url($this->file_path);
    }

    public static function matchCategory(string $fileName, ?string $hint = null): string
    {
        $haystack = strtolower(trim(($hint ?? '').' '.$fileName));

        $map = [
            'akad' => ['akad', 'nikah', 'ijab', 'khutbah', 'mahar', 'kua', 'penghulu', 'buku nikah'],
            'resepsi' => ['resepsi', 'dekorasi', 'ballroom', 'undangan', 'souvenir', 'dokumentasi'],
            'keuangan' => ['anggaran', 'budget', 'keuangan', 'biaya', 'pembayaran', 'kwitansi', 'invoice', 'rincian'],
            'vendor' => ['vendor', 'catering', 'mua', 'wedding organizer', 'wo', 'kontrak'],
        ];

        foreach ($map as $category => $keywords) {
            foreach ($keywords as $keyword) {
                if (str_contains($haystack, $keyword)) {
                    return $category;
                }
            }
        }

        $extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

        if (in_array($extension, ['xls', 'xlsx', 'csv'], true)) {
            return 'keuangan';
        }

        return 'vendor';
    }
}
