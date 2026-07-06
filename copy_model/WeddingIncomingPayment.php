<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingIncomingPayment extends Model
{
    protected $fillable = [
        'user_id',
        'bank_name',
        'amount',
        'transfer_date',
        'sender_name',
        'description',
        'reference_number',
        'proof_url',
        'status',
        'confirmed_at',
        'confirmed_by',
        'rejection_reason',
        'notes',
    ];

    protected $casts = [
        'amount'        => 'decimal:2',
        'transfer_date' => 'date',
        'confirmed_at'  => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function getStatusLabelAttribute(): string
    {
        return match ($this->status) {
            'confirmed' => 'Dikonfirmasi',
            'rejected'  => 'Ditolak',
            default     => 'Menunggu',
        };
    }
}
