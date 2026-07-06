<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FamilyMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'no',
        'name',
        'role',
        'phone',
        'rsvp_status',
        'rsvp_updated_by_name',
        'rsvp_updated_at',
    ];

    protected $casts = [
        'rsvp_updated_at' => 'datetime',
    ];

    public static array $rsvpOptions = [
        'menunggu'     => 'Menunggu',
        'hadir'        => 'Hadir',
        'tidak_hadir'  => 'Tidak Hadir',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
