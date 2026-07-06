<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;
use Illuminate\Database\Eloquent\Relations\HasOne;

class WeddingInfo extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 
        'groom_name',
        'bride_name',
        'budaya',
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
        return $this->hasMany(WeddingEvent::class, 'user_id', 'user_id')
                    ->orderBy('tgl_acara');
    }

    public function familyMembers(): HasMany
    {
        return $this->hasMany(FamilyMember::class, 'user_id', 'user_id');
    }

    public function budget(): HasOne
    {
        return $this->hasOne(WeddingBudget::class, 'user_id', 'user_id');
    }

    public function preparationTasks(): HasManyThrough
    {
        return $this->hasManyThrough(
            CustomerPreparationTask::class,
            WeddingEvent::class,
            'user_id',          // FK pada wedding_events → menuju user_id WeddingInfo
            'wedding_event_id', // FK pada customer_preparation_tasks → menuju id WeddingEvent
            'user_id',          // local key pada wedding_infos
            'id',               // local key pada wedding_events
        );
    }
}
