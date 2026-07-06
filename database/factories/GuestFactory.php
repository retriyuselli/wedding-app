<?php

namespace Database\Factories;

use App\Models\Guest;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Guest>
 */
class GuestFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'               => User::factory(),
            'name'                  => fake()->name(),
            'phone'                 => fake()->phoneNumber(),
            'email'                 => fake()->optional()->safeEmail(),
            'table_number'          => (string) fake()->numberBetween(1, 30),
            'rsvp_status'           => fake()->randomElement(array_keys(Guest::$rsvpOptions)),
            'rsvp_updated_by_name'  => null,
            'rsvp_updated_at'       => null,
            'catatan'               => fake()->optional()->sentence(),
        ];
    }
}
