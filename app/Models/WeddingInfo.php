<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class WeddingInfo extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'groom_name',
        'groom_full_name',
        'groom_phone',
        'groom_father_name',
        'groom_mother_name',
        'bride_name',
        'bride_full_name',
        'bride_phone',
        'bride_father_name',
        'bride_mother_name',
        'budaya',
        'couple_photo',
        'songlist',
    ];

    protected $casts = [
        'songlist' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function events(): HasMany
    {
        return $this->hasMany(WeddingEvent::class, 'user_id', 'user_id')->orderBy('sort_order')->orderBy('tgl_acara');
    }

    public function familyMembers(): HasMany
    {
        return $this->hasMany(FamilyMember::class, 'user_id', 'user_id');
    }

    public function budget(): HasOne
    {
        return $this->hasOne(WeddingBudget::class, 'user_id', 'user_id');
    }

    public function couplePhotoUrl(): ?string
    {
        if (! $this->couple_photo) {
            return null;
        }

        if (str_starts_with($this->couple_photo, 'http://') || str_starts_with($this->couple_photo, 'https://')) {
            return $this->couple_photo;
        }

        return asset('storage/'.ltrim($this->couple_photo, '/'));
    }

    public function getCoupleNamesAttribute(): string
    {
        $names = collect([$this->groom_name, $this->bride_name])
            ->filter()
            ->implode(' & ');

        return $names !== '' ? $names : 'Belum diisi';
    }
}
