<?php

namespace Database\Factories;

use App\Models\FamilyMember;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<FamilyMember>
 */
class FamilyMemberFactory extends Factory
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
            'no'                    => null,
            'name'                  => fake()->name(),
            'role'                  => fake()->randomElement(['Ayah', 'Ibu', 'Kakak', 'Adik', 'Paman', 'Bibi']),
            'phone'                 => fake()->phoneNumber(),
            'rsvp_status'           => fake()->randomElement(array_keys(FamilyMember::$rsvpOptions)),
            'rsvp_updated_by_name'  => null,
            'rsvp_updated_at'       => null,
        ];
    }
}
