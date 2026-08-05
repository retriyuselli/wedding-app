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
        $groomName = fake()->firstNameMale();
        $brideName = fake()->firstNameFemale();

        return [
            'user_id' => User::factory(),
            'groom_name' => $groomName,
            'groom_full_name' => $groomName.' '.fake()->lastName(),
            'groom_phone' => '08'.fake()->numerify('##########'),
            'groom_father_name' => fake()->name('male'),
            'groom_mother_name' => fake()->name('female'),
            'bride_name' => $brideName,
            'bride_full_name' => $brideName.' '.fake()->lastName(),
            'bride_phone' => '08'.fake()->numerify('##########'),
            'bride_father_name' => fake()->name('male'),
            'bride_mother_name' => fake()->name('female'),
            'budaya' => fake()->randomElement(['Jawa', 'Sunda', 'Minang', 'Batak', 'Bali', 'Betawi']),
            'couple_photo' => null,
            'songlist' => fake()->randomElements([
                'Perfect - Ed Sheeran',
                'A Thousand Years - Christina Perri',
                'Marry You - Bruno Mars',
                'All of Me - John Legend',
                'Sempurna - Andra and The Backbone',
            ], 3),
        ];
    }
}
