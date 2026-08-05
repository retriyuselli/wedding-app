<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WeddingEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'jenis_acara',
        'sort_order',
        'tgl_acara',
        'waktu_mulai',
        'jam_selesai',
        'lokasi_acara',
        'estimasi_tamu',
        'vendor_booking_id',
        'catatan',
    ];

    protected function casts(): array
    {
        return [
            'tgl_acara' => 'date',
            'sort_order' => 'integer',
            'estimasi_tamu' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (WeddingEvent $event): void {
            if ($event->sort_order !== null && $event->sort_order > 0) {
                return;
            }

            $maxOrder = static::query()
                ->where('user_id', $event->user_id)
                ->max('sort_order');

            $event->sort_order = ((int) $maxOrder) + 1;
        });
    }

    public static array $jenisOptions = [
        'lamaran' => 'Lamaran',
        'pengajian' => 'Pengajian',
        'akad' => 'Akad Nikah',
        'resepsi' => 'Resepsi',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function preparationTasks(): HasMany
    {
        return $this->hasMany(CustomerPreparationTask::class, 'wedding_event_id')->orderBy('sort_order');
    }

    public function paymentSchedules(): HasMany
    {
        return $this->hasMany(WeddingPaymentSchedule::class, 'wedding_event_id');
    }

    public function getJenisLabelAttribute(): string
    {
        return self::$jenisOptions[$this->jenis_acara] ?? $this->jenis_acara;
    }
}
