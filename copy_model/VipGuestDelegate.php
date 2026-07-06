<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class VipGuestDelegate extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'claimed_by_user_id',
        'name',
        'token',
        'expires_at',
        'last_accessed_at',
    ];

    protected $casts = [
        'expires_at'        => 'datetime',
        'last_accessed_at'  => 'datetime',
    ];

    public static function generateToken(): string
    {
        do {
            $token = Str::random(48);
        } while (self::where('token', $token)->exists());

        return $token;
    }

    public function isExpired(): bool
    {
        return $this->expires_at !== null && $this->expires_at->isPast();
    }

    public function isActive(): bool
    {
        return ! $this->isExpired();
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function claimedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'claimed_by_user_id');
    }
}
