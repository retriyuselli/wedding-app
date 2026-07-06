<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\VipGuest;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<VipGuest>
 */
class VipGuestFactory extends Factory
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
            'jabatan'               => fake()->jobTitle(),
            'instansi'              => fake()->company(),
            'phone'                 => fake()->phoneNumber(),
            'kategori'              => fake()->randomElement(array_keys(VipGuest::$kategoriOptions)),
            'rsvp_status'           => fake()->randomElement(array_keys(VipGuest::$rsvpOptions)),
            'rsvp_updated_by_name'  => null,
            'rsvp_updated_at'       => null,
            'catatan'               => fake()->optional()->sentence(),
        ];
    }
}
