<?php

namespace Database\Factories;

use App\Models\CustomerPreparationTask;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CustomerPreparationTask>
 */
class CustomerPreparationTaskFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'          => User::factory(),
            'wedding_event_id' => null,
            'section_id'       => null,
            'title'            => fake()->sentence(3),
            'label'            => null,
            'status'           => fake()->randomElement(array_keys(CustomerPreparationTask::$statusOptions)),
            'due_date'         => fake()->dateTimeBetween('now', '+6 months'),
            'sort_order'       => 0,
        ];
    }
}
