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
        'amount'                     => 'decimal:2',
        'due_date'                   => 'date',
        'paid_at'                    => 'datetime',
        'wedding_event_id'           => 'integer',
        'customer_payment_method_id' => 'integer',
        'sort_order'                 => 'integer',
    ];

    public static array $categoryOptions = [
        'venue'         => 'Venue',
        'catering'      => 'Catering',
        'decoration'    => 'Dekorasi',
        'photo_video'   => 'Foto & Video',
        'entertainment' => 'Entertainment',
        'makeup'        => 'Makeup & Busana',
        'transport'     => 'Transportasi',
        'wo'            => 'Wedding Organizer',
        'other'         => 'Lainnya',
    ];

    public static array $statusOptions = [
        'pending' => 'Belum Bayar',
        'paid'    => 'Sudah Bayar',
        'overdue' => 'Overdue',
    ];

    protected static function booted(): void
    {
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
