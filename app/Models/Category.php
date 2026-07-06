<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    use HasFactory;
    protected $fillable = [
        'name',
        'slug',
        'icon',
        'description',
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

    public function vendors(): HasMany
    {
        return $this->hasMany(Vendor::class);
    }

    protected static function booted(): void
    {
        static::creating(function (Category $category): void {
            if ($category->sort_order === null) {
                $category->sort_order = (int) static::query()->max('sort_order') + 1;
            }
        });
    }
}
