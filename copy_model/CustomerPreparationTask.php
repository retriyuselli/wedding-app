<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerPreparationTask extends Model
{
    use HasFactory;

    protected $fillable = [
        'wedding_event_id',
        'section_id',
        'label',
        'user_id',
        'title',
        'status',
        'due_date',
        'sort_order',
    ];

    protected $casts = [
        'due_date' => 'date',
    ];

    public function weddingEvent(): BelongsTo
    {
        return $this->belongsTo(WeddingEvent::class, 'wedding_event_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
