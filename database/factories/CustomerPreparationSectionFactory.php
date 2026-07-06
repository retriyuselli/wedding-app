<?php

namespace Database\Factories;

use App\Models\CustomerPreparationSection;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CustomerPreparationSection>
 */
class CustomerPreparationSectionFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'    => User::factory(),
            'title'      => fake()->randomElement(['Dokumen', 'Vendor', 'Busana', 'Venue', 'Undangan']),
            'icon'       => null,
            'sort_order' => 0,
        ];
    }
}
