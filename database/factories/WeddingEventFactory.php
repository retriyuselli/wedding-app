<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\WeddingEvent;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingEvent>
 */
class WeddingEventFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'            => User::factory(),
            'jenis_acara'        => fake()->randomElement(array_keys(WeddingEvent::$jenisOptions)),
            'tgl_acara'          => fake()->dateTimeBetween('now', '+1 year'),
            'lokasi_acara'       => fake()->city().', Indonesia',
            'vendor_booking_id'  => null,
            'catatan'            => fake()->optional()->sentence(),
        ];
    }
}
