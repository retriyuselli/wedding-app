<?php

namespace App\Models\Paket;

use App\Support\DummyImage;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Read-only mirror of paketpernikahan.co.id vendors table.
 */
class Vendor extends Model
{
    protected $connection = 'mysql_paket';

    protected $table = 'vendors';

    public $timestamps = true;

    protected $guarded = ['*'];

    protected $appends = [
        'logo',
        'address',
        'website',
        'is_verified',
        'is_featured',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'badge' => 'array',
            'promo' => 'array',
            'categories' => 'array',
            'cover_image' => 'array',
            'is_active' => 'boolean',
            'is_profile_complete' => 'boolean',
            'rating' => 'float',
            'discount' => 'integer',
            'experience' => 'integer',
            'events_done' => 'integer',
            'likes' => 'integer',
            'comments_count' => 'integer',
            'price_start' => 'integer',
        ];
    }

    public function getRouteKeyName(): string
    {
        return 'slug';
    }

    /** Related category row (FK column is also named `category` / slug). */
    public function categoryVendor(): BelongsTo
    {
        return $this->belongsTo(CategoryVendor::class, 'category', 'slug');
    }

    public function displayCategoryName(): string
    {
        return $this->categoryVendor?->name ?? 'Vendor';
    }

    public function packages(): HasMany
    {
        return $this->hasMany(VendorPackage::class)->orderBy('sort_order');
    }

    public function activePackages(): HasMany
    {
        return $this->packages()->where('is_active', true);
    }

    public function getLogoAttribute(): ?string
    {
        return $this->attributes['logo_vendor'] ?? null;
    }

    public function getAddressAttribute(): ?string
    {
        return $this->attributes['location'] ?? null;
    }

    public function getWebsiteAttribute(): ?string
    {
        return null;
    }

    public function getIsVerifiedAttribute(): bool
    {
        return (bool) ($this->attributes['is_profile_complete'] ?? false);
    }

    public function getIsFeaturedAttribute(): bool
    {
        $badge = $this->badge;
        $promo = $this->promo;

        return (is_array($badge) && $badge !== []) || (is_array($promo) && $promo !== []);
    }

    public function getSortOrderAttribute(): int
    {
        return 0;
    }

    public function displayRating(): float
    {
        $rating = $this->rating;

        if ($rating !== null && (float) $rating > 0) {
            return round((float) $rating, 1);
        }

        return round(4.0 + (($this->id * 7) % 10) / 10, 1);
    }

    public function reviewCount(): int
    {
        $count = (int) ($this->comments_count ?? 0);

        return $count > 0 ? $count : 40 + (($this->id * 13) % 180);
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
        $value = $this->cover_image;
        $path = is_array($value) ? ($value[0] ?? null) : $value;

        if (! $path) {
            return null;
        }

        if (str_starts_with((string) $path, 'http://') || str_starts_with((string) $path, 'https://')) {
            return (string) $path;
        }

        return rtrim((string) config('wedding.vendors.paket_public_url'), '/').'/storage/'.$path;
    }

    public function logoUrl(): ?string
    {
        $path = $this->logo;
        if (! $path) {
            return null;
        }

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }

        return rtrim((string) config('wedding.vendors.paket_public_url'), '/').'/storage/'.$path;
    }

    /**
     * Filter by one or more paket category slugs (primary category or categories JSON).
     *
     * @param  list<string>  $slugs
     */
    public function scopeWhereCategorySlugs(Builder $query, array $slugs): Builder
    {
        if ($slugs === []) {
            return $query;
        }

        return $query->where(function (Builder $inner) use ($slugs): void {
            $inner->whereIn('category', $slugs);

            foreach ($slugs as $slug) {
                $inner->orWhereJsonContains('categories', $slug);
            }
        });
    }
}
