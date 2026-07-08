<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\WeddingBudgetCategoryAllocation;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingBudgetCategoryAllocation>
 */
class WeddingBudgetCategoryAllocationFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'category' => fake()->randomElement(array_keys(WeddingPaymentSchedule::$categoryOptions)),
            'allocated_amount' => fake()->numberBetween(5, 100) * 1_000_000,
            'notes' => fake()->optional()->sentence(),
        ];
    }
}
