<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class VendorPackage extends Model
{
    /** @use HasFactory<\Database\Factories\VendorPackageFactory> */
    use HasFactory;

    protected $fillable = [
        'vendor_id',
        'name',
        'slug',
        'description',
        'price',
        'price_type',
        'capacity_min',
        'capacity_max',
        'duration_hours',
        'inclusions',
        'facility_sections',
        'exclusions',
        'cover_image',
        'is_active',
        'is_featured',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'price_type' => VendorPackagePriceType::class,
            'capacity_min' => 'integer',
            'capacity_max' => 'integer',
            'duration_hours' => 'integer',
            'inclusions' => 'array',
            'facility_sections' => 'array',
            'exclusions' => 'array',
            'is_active' => 'boolean',
            'is_featured' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    /**
     * @return list<string>
     */
    public function flattenedInclusions(): array
    {
        if (is_array($this->facility_sections) && $this->facility_sections !== []) {
            return collect($this->facility_sections)
                ->flatMap(fn (array $section): array => $section['items'] ?? [])
                ->values()
                ->all();
        }

        return $this->inclusions ?? [];
    }

    protected static function booted(): void
    {
        static::creating(function (VendorPackage $package): void {
            if ($package->sort_order !== null || $package->vendor_id === null) {
                return;
            }

            $package->sort_order = (int) static::query()
                ->where('vendor_id', $package->vendor_id)
                ->max('sort_order') + 1;
        });
    }
}
