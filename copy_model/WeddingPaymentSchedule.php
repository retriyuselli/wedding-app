<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingPaymentSchedule extends Model
{
    protected $fillable = [
        'user_id',
        'wedding_event_id',
        'source_template_id',
        'title',
        'vendor_name',
        'category',
        'amount',
        'due_date',
        'status',
        'paid_at',
        'customer_payment_method_id',
        'proof_url',
        'notes',
        'sort_order',
    ];

    protected $casts = [
        'amount'   => 'decimal:2',
        'due_date' => 'date',
        'paid_at'  => 'datetime',
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

    public function sourceTemplate(): BelongsTo
    {
        return $this->belongsTo(WeddingPaymentScheduleTemplate::class, 'source_template_id');
    }

    public function paymentMethod(): BelongsTo
    {
        return $this->belongsTo(CustomerPaymentMethod::class, 'customer_payment_method_id');
    }

    public function getCategoryLabelAttribute(): string
    {
        return match ($this->category) {
            'venue'         => 'Venue',
            'catering'      => 'Catering',
            'decoration'    => 'Dekorasi',
            'photo_video'   => 'Foto & Video',
            'entertainment' => 'Entertainment',
            'makeup'        => 'Makeup & Busana',
            'transport'     => 'Transportasi',
            'wo'            => 'Wedding Organizer',
            default         => 'Lainnya',
        };
    }

    public function getCategoryIconAttribute(): string
    {
        return match ($this->category) {
            'venue'         => 'building.2',
            'catering'      => 'fork.knife',
            'decoration'    => 'sparkles',
            'photo_video'   => 'camera',
            'entertainment' => 'music.note.list',
            'makeup'        => 'person.crop.rectangle.stack',
            'transport'     => 'car',
            'wo'            => 'person.crop.circle',
            default         => 'doc.text',
        };
    }
}
