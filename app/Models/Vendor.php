<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Vendor extends Model
{
    use HasFactory;
    protected $fillable = [
        'category_id',
        'name',
        'slug',
        'logo',
        'cover_image',
        'description',
        'province',
        'city',
        'address',
        'phone',
        'email',
        'website',
        'instagram',
        'is_verified',
        'is_featured',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'is_verified' => 'boolean',
            'is_featured' => 'boolean',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function packages(): HasMany
    {
        return $this->hasMany(VendorPackage::class)->orderBy('sort_order');
    }

    public function activePackages(): HasMany
    {
        return $this->packages()->where('is_active', true);
    }

    protected static function booted(): void
    {
        static::creating(function (Vendor $vendor): void {
            if ($vendor->sort_order === null) {
                $vendor->sort_order = (int) static::query()->max('sort_order') + 1;
            }
        });
    }
}
