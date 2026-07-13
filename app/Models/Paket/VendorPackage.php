<?php

namespace App\Models\Paket;

use App\Models\VendorPackagePriceType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Read-only mirror of paketpernikahan.co.id vendor_packages.
 */
class VendorPackage extends Model
{
    protected $connection = 'mysql_paket';

    protected $table = 'vendor_packages';

    public $timestamps = true;

    protected $guarded = ['*'];

    protected function casts(): array
    {
        return [
            'image_path' => 'array',
            'facilities' => 'array',
            'category_vendor_id' => 'array',
            'is_active' => 'boolean',
            'discount_expires_at' => 'datetime',
            'price' => 'integer',
            'discount' => 'integer',
            'sort_order' => 'integer',
            'max_guests' => 'integer',
        ];
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function getPriceTypeAttribute(): ?VendorPackagePriceType
    {
        return VendorPackagePriceType::Fixed;
    }

    public function getCapacityMinAttribute(): ?int
    {
        return null;
    }

    public function getCapacityMaxAttribute(): ?int
    {
        $max = $this->attributes['max_guests'] ?? null;

        if ($max === null || (int) $max <= 0) {
            return null;
        }

        return (int) $max;
    }

    public function getDurationHoursAttribute(): ?int
    {
        return null;
    }

    public function getInclusionsAttribute(): array
    {
        return $this->flattenedInclusions();
    }

    public function getFacilitySectionsAttribute(): array
    {
        $facilities = $this->facilities;

        if (is_array($facilities) && $facilities !== []) {
            return [[
                'title' => 'Fasilitas',
                'items' => array_values(array_filter(array_map(
                    fn ($item): string => is_string($item) ? trim($item) : trim((string) $item),
                    $facilities,
                ))),
            ]];
        }

        return [];
    }

    public function getExclusionsAttribute(): array
    {
        return [];
    }

    public function getCoverImageAttribute(): ?string
    {
        $paths = $this->attributes['image_path'] ?? null;
        $decoded = is_string($paths) ? json_decode($paths, true) : $paths;

        if (is_array($decoded)) {
            return $decoded[0] ?? null;
        }

        return is_string($paths) && $paths !== '' ? $paths : null;
    }

    public function getIsFeaturedAttribute(): bool
    {
        return false;
    }

    public function getDescriptionAttribute(): ?string
    {
        return null;
    }

    /**
     * Final package price after discount (compatible with wedding-app starting_price).
     */
    public function getFinalPriceAttribute(): float
    {
        return max(0, (float) ($this->attributes['price'] ?? 0) - (float) ($this->attributes['discount'] ?? 0));
    }

    /**
     * @return list<string>
     */
    public function flattenedInclusions(): array
    {
        $sections = $this->facility_sections;
        if ($sections !== []) {
            return collect($sections)
                ->flatMap(fn (array $section): array => $section['items'] ?? [])
                ->values()
                ->all();
        }

        $itemHtml = $this->attributes['item'] ?? null;
        if (! is_string($itemHtml) || trim($itemHtml) === '') {
            return [];
        }

        if (preg_match_all('/<li[^>]*>(.*?)<\/li>/is', $itemHtml, $matches)) {
            return collect($matches[1])
                ->map(fn (string $text): string => trim(html_entity_decode(strip_tags($text))))
                ->filter()
                ->values()
                ->all();
        }

        $plain = trim(html_entity_decode(strip_tags($itemHtml)));

        return $plain !== '' ? [$plain] : [];
    }

    public function coverImageUrl(): ?string
    {
        $path = $this->cover_image;
        if (! $path) {
            return null;
        }

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }

        return rtrim((string) config('wedding.vendors.paket_public_url'), '/').'/storage/'.$path;
    }
}
