<?php

namespace Database\Factories;

use App\Models\Vendor;
use App\Models\VendorPackage;
use App\Models\VendorPackagePriceType;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<VendorPackage>
 */
class VendorPackageFactory extends Factory
{
    protected $model = VendorPackage::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $name = 'Paket '.fake()->words(2, true);

        return [
            'vendor_id' => Vendor::factory(),
            'name' => Str::title($name),
            'slug' => Str::slug($name.'-'.fake()->unique()->numerify('###')),
            'description' => fake()->paragraph(),
            'price' => fake()->randomElement([3500000, 8500000, 15000000, 35000000, 65000000]),
            'price_type' => fake()->randomElement(VendorPackagePriceType::cases()),
            'capacity_min' => fake()->optional()->numberBetween(50, 200),
            'capacity_max' => fake()->optional()->numberBetween(201, 1000),
            'duration_hours' => fake()->optional()->numberBetween(4, 12),
            'inclusions' => fake()->randomElements(
                ['Dekor pelaminan', 'Sound system', 'Make up pengantin', 'Dokumentasi', 'Catering'],
                fake()->numberBetween(2, 4),
            ),
            'exclusions' => null,
            'cover_image' => null,
            'is_active' => true,
            'is_featured' => fake()->boolean(25),
            'sort_order' => fake()->numberBetween(1, 10),
        ];
    }
}
