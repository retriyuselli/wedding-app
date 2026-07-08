<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerNotification extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'group',
        'title',
        'message',
        'icon',
        'destination',
        'tint',
        'is_unread',
    ];

    protected $casts = [
        'is_unread' => 'boolean',
    ];

    public static array $groupOptions = [
        'payment' => 'Pembayaran',
        'guest' => 'Tamu',
        'preparation' => 'Persiapan',
        'system' => 'Sistem',
    ];

    public static array $tintOptions = [
        'success' => 'Sukses',
        'warning' => 'Peringatan',
        'danger' => 'Penting',
        'info' => 'Info',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
