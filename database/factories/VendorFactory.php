<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Vendor>
 */
class VendorFactory extends Factory
{
    protected $model = Vendor::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $name = fake()->company();

        return [
            'category_id' => Category::factory(),
            'name' => $name,
            'slug' => Str::slug($name.'-'.fake()->unique()->numerify('###')),
            'logo' => null,
            'cover_image' => null,
            'description' => fake()->optional()->paragraph(),
            'province' => 'Sumatera Selatan',
            'city' => 'Palembang',
            'address' => fake()->optional()->address(),
            'phone' => fake()->phoneNumber(),
            'email' => fake()->optional()->companyEmail(),
            'website' => fake()->optional()->url(),
            'instagram' => '@'.Str::slug(fake()->userName()),
            'is_verified' => fake()->boolean(70),
            'is_featured' => fake()->boolean(30),
            'is_active' => true,
            'sort_order' => fake()->numberBetween(1, 50),
        ];
    }
}
