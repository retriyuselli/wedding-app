<?php

namespace App\Models;

use Database\Factories\TrustedDeviceFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TrustedDevice extends Model
{
    /** @use HasFactory<TrustedDeviceFactory> */
    use HasFactory;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'device_name',
        'device_identifier',
        'platform',
        'is_trusted',
        'last_used_at',
        'trusted_at',
        'personal_access_token_id',
    ];

    protected function casts(): array
    {
        return [
            'is_trusted' => 'boolean',
            'last_used_at' => 'datetime',
            'trusted_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
