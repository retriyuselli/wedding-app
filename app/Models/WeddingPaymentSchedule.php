<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingPaymentSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'wedding_event_id',
        'source_template_id',
        'customer_payment_method_id',
        'title',
        'vendor_name',
        'category',
        'amount',
        'due_date',
        'status',
        'paid_at',
        'proof_url',
        'notes',
        'sort_order',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'due_date' => 'date',
        'paid_at' => 'datetime',
        'wedding_event_id' => 'integer',
        'customer_payment_method_id' => 'integer',
        'sort_order' => 'integer',
    ];

    public static array $categoryOptions = [
        'venue' => 'Venue',
        'catering' => 'Catering',
        'decoration' => 'Dekorasi',
        'photo_video' => 'Foto & Video',
        'entertainment' => 'Entertainment',
        'makeup' => 'Makeup & Busana',
        'transport' => 'Transportasi',
        'wo' => 'Wedding Organizer',
        'other' => 'Lainnya',
    ];

    public static array $categoryIcons = [
        'venue' => 'building.columns',
        'catering' => 'fork.knife',
        'decoration' => 'leaf',
        'photo_video' => 'camera',
        'entertainment' => 'music.note',
        'makeup' => 'figure.dress.line.vertical.figure',
        'transport' => 'car',
        'wo' => 'person.badge.shield.checkmark',
        'other' => 'ellipsis',
    ];

    public static array $categoryDescriptions = [
        'venue' => 'Gedung, sewa tempat, dll',
        'catering' => 'Makanan & minuman tamu',
        'decoration' => 'Dekorasi akad & resepsi',
        'photo_video' => 'Foto, video, dokumentasi',
        'entertainment' => 'Musik, hiburan, MC',
        'makeup' => 'Busana & rias pengantin',
        'transport' => 'Transportasi tamu & keluarga',
        'wo' => 'Wedding organizer & koordinasi',
        'other' => 'Biaya lain-lain',
    ];

    public static array $statusOptions = [
        'pending' => 'Belum Bayar',
        'paid' => 'Sudah Bayar',
        'overdue' => 'Terlambat',
    ];

    protected static function booted(): void
    {
        static::creating(function (self $schedule): void {
            if ($schedule->sort_order === null && $schedule->user_id !== null) {
                $maxOrder = static::query()
                    ->where('user_id', $schedule->user_id)
                    ->max('sort_order');

                $schedule->sort_order = ((int) $maxOrder) + 1;
            }
        });

        static::retrieved(function (self $schedule): void {
            if ($schedule->status === 'pending' && $schedule->due_date?->isPast()) {
                $schedule->updateQuietly(['status' => 'overdue']);
            }
        });
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function weddingEvent(): BelongsTo
    {
        return $this->belongsTo(WeddingEvent::class);
    }

    public function paymentMethod(): BelongsTo
    {
        return $this->belongsTo(CustomerPaymentMethod::class, 'customer_payment_method_id');
    }

    public function getCategoryLabelAttribute(): string
    {
        return self::$categoryOptions[$this->category] ?? 'Lainnya';
    }

    public function getStatusLabelAttribute(): string
    {
        return self::$statusOptions[$this->status] ?? $this->status;
    }

    public static function categoryDescription(string $category): string
    {
        return self::$categoryDescriptions[$category] ?? 'Alokasi anggaran kategori';
    }

    /**
     * @return list<array{key: string, label: string, icon: string, description: string}>
     */
    public static function paymentCategoriesForApi(): array
    {
        return collect(self::$categoryOptions)
            ->map(fn (string $label, string $key): array => [
                'key' => $key,
                'label' => $label,
                'icon' => self::$categoryIcons[$key] ?? config('wedding.default_category_icon', 'ellipsis'),
                'description' => self::categoryDescription($key),
            ])
            ->values()
            ->all();
    }

    /**
     * @return array<string, string>
     */
    public static function budgetDefaultsForApi(): array
    {
        return [
            'default_currency' => WeddingBudget::defaultCurrency(),
            'default_expense_category' => config('wedding.default_expense_category', 'other'),
            'default_category_icon' => config('wedding.default_category_icon', 'ellipsis'),
            'default_expense_status' => config('wedding.default_expense_status', 'pending'),
            'default_incoming_payment_status' => config('wedding.default_incoming_payment_status', 'menunggu'),
        ];
    }

    public function proofUrl(): ?string
    {
        if (! $this->proof_url) {
            return null;
        }

        if (str_starts_with($this->proof_url, 'http://') || str_starts_with($this->proof_url, 'https://')) {
            return $this->proof_url;
        }

        return asset('storage/'.ltrim($this->proof_url, '/'));
    }
}
