<?php

namespace App\Models;

use App\Support\DummyImage;
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

    public function displayCategoryName(): string
    {
        return $this->category?->name ?? 'Vendor';
    }

    public function packages(): HasMany
    {
        return $this->hasMany(VendorPackage::class)->orderBy('sort_order');
    }

    public function activePackages(): HasMany
    {
        return $this->packages()->where('is_active', true);
    }

    public function displayRating(): float
    {
        return round(4.0 + (($this->id * 7) % 10) / 10, 1);
    }

    public function reviewCount(): int
    {
        return 40 + (($this->id * 13) % 180);
    }

    public function locationLabel(): string
    {
        return collect([$this->city, $this->province])
            ->filter()
            ->implode(', ') ?: 'Indonesia';
    }

    public function coverImageUrl(): string
    {
        return $this->resolvedCoverUrl() ?? DummyImage::url('vendor', $this->id);
    }

    public function resolvedCoverUrl(): ?string
    {
        if (! $this->cover_image) {
            return null;
        }

        return asset('storage/'.$this->cover_image);
    }

    public function logoUrl(): ?string
    {
        if (! $this->logo) {
            return null;
        }

        return asset('storage/'.$this->logo);
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
