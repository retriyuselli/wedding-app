<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WeddingQuote extends Model
{
    /** @use HasFactory<\Database\Factories\WeddingQuoteFactory> */
    use HasFactory;

    protected $fillable = [
        'quote',
        'sort_order',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (WeddingQuote $quote): void {
            if ($quote->sort_order === null) {
                $quote->sort_order = (int) static::query()->max('sort_order') + 1;
            }
        });
    }
}
