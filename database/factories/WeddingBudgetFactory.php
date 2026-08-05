<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\WeddingBudget;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingBudget>
 */
class WeddingBudgetFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'total_budget' => fake()->numberBetween(50, 500) * 1_000_000,
            'currency' => WeddingBudget::defaultCurrency(),
            'notes' => fake()->optional()->sentence(),
        ];
    }
}
