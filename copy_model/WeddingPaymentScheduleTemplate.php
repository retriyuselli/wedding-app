<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WeddingPaymentScheduleTemplate extends Model
{
    protected $fillable = [
        'jenis_acara',
        'title',
        'vendor_name',
        'category',
        'amount',
        'due_days_before_event',
        'notes',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'amount'                 => 'decimal:2',
        'due_days_before_event'  => 'integer',
        'sort_order'             => 'integer',
        'is_active'              => 'boolean',
    ];

    public static array $jenisOptions = [
        'lamaran'   => 'Lamaran',
        'pengajian' => 'Pengajian',
        'akad'      => 'Akad Nikah',
        'resepsi'   => 'Resepsi',
    ];

    public function schedules(): HasMany
    {
        return $this->hasMany(WeddingPaymentSchedule::class, 'source_template_id');
    }
}
