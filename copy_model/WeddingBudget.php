<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingBudget extends Model
{
    protected $fillable = [
        'user_id',
        'total_budget',
        'currency',
        'notes',
    ];

    protected $casts = [
        'total_budget' => 'decimal:2',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
