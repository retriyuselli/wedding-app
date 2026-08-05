<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WeddingBudget extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'total_budget',
        'currency',
        'notes',
    ];

    protected $casts = [
        'total_budget' => 'decimal:2',
    ];

    public static array $currencyOptions = [
        'IDR' => 'Rupiah (IDR)',
    ];

    public static function defaultCurrency(): string
    {
        return config('wedding.default_currency', 'IDR');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function paymentSchedules(): HasMany
    {
        return $this->hasMany(WeddingPaymentSchedule::class, 'user_id', 'user_id');
    }

    public function incomingPayments(): HasMany
    {
        return $this->hasMany(WeddingIncomingPayment::class, 'user_id', 'user_id');
    }

    public function categoryAllocations(): HasMany
    {
        return $this->hasMany(WeddingBudgetCategoryAllocation::class, 'user_id', 'user_id');
    }
}
