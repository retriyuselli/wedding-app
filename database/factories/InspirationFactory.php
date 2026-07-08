<?php

namespace Database\Factories;

use App\Models\Inspiration;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Inspiration>
 */
class InspirationFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => fake()->sentence(3),
            'description' => fake()->sentence(12),
            'category' => fake()->randomElement(array_keys(Inspiration::$categoryOptions)),
            'image_url' => fake()->optional()->imageUrl(640, 480),
            'thumbnail_symbol' => fake()->randomElement(['sparkles', 'leaf.fill', 'paintpalette.fill', 'camera.fill']),
            'likes_count' => fake()->numberBetween(100, 2500),
            'views_count' => fake()->numberBetween(500, 5000),
            'is_active' => true,
            'sort_order' => fake()->numberBetween(1, 100),
        ];
    }
}
