<?php

namespace Database\Factories;

use App\Models\WeddingQuote;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingQuote>
 */
class WeddingQuoteFactory extends Factory
{
    protected $model = WeddingQuote::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'quote' => fake()->sentence(12),
            'sort_order' => fake()->numberBetween(1, 20),
            'is_active' => true,
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (): array => [
            'is_active' => false,
        ]);
    }
}
