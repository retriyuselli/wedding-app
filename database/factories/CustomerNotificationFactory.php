<?php

namespace Database\Factories;

use App\Models\CustomerNotification;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CustomerNotification>
 */
class CustomerNotificationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'     => User::factory(),
            'group'       => fake()->randomElement(['payment', 'guest', 'preparation', 'system']),
            'title'       => fake()->sentence(4),
            'message'     => fake()->sentence(),
            'icon'        => null,
            'destination' => null,
            'tint'        => fake()->randomElement(['success', 'warning', 'danger', 'info']),
            'is_unread'   => fake()->boolean(),
        ];
    }
}
