<?php

namespace App\Models\Paket;

use App\Models\VendorPackagePriceType;
use App\Support\RichEditorFacilityParser;
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

    /**
     * Prefer RichEditor `item` HTML (Filament), then JSON facilities column.
     *
     * @return list<array{title: string, items: list<string>}>
     */
    public function getFacilitySectionsAttribute(): array
    {
        $fromItem = RichEditorFacilityParser::toSections($this->attributes['item'] ?? null);
        if ($fromItem !== []) {
            return $fromItem;
        }

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
     * Raw Filament RichEditor HTML from paketpernikahan `item` column.
     */
    public function itemHtml(): ?string
    {
        $html = $this->attributes['item'] ?? null;

        return is_string($html) && trim($html) !== '' ? $html : null;
    }

    public function getFinalPriceAttribute(): float
    {
        return max(0, (float) ($this->attributes['price'] ?? 0) - (float) ($this->attributes['discount'] ?? 0));
    }

    /**
     * @return list<string>
     */
    public function flattenedInclusions(): array
    {
        return collect($this->facility_sections)
            ->flatMap(fn (array $section): array => $section['items'] ?? [])
            ->values()
            ->all();
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
