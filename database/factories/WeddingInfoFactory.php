<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\WeddingInfo;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingInfo>
 */
class WeddingInfoFactory extends Factory
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
            'groom_name' => fake()->firstNameMale(),
            'bride_name' => fake()->firstNameFemale(),
            'budaya'     => fake()->randomElement(['Jawa', 'Sunda', 'Minang', 'Batak', 'Bali', 'Betawi']),
            'songlist'   => fake()->randomElements([
                'Perfect - Ed Sheeran',
                'A Thousand Years - Christina Perri',
                'Marry You - Bruno Mars',
                'All of Me - John Legend',
                'Sempurna - Andra and The Backbone',
            ], 3),
        ];
    }
}
