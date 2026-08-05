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
            'user_id' => User::factory(),
            'jenis_acara' => fake()->randomElement(array_keys(WeddingEvent::$jenisOptions)),
            'sort_order' => 0,
            'tgl_acara' => fake()->dateTimeBetween('now', '+1 year'),
            'waktu_mulai' => fake()->randomElement(['09:00', '10:00', '11:30', '14:00']),
            'jam_selesai' => fake()->randomElement(['11:00', '12:00', '15:00', '16:00']),
            'lokasi_acara' => fake()->city().', Indonesia',
            'estimasi_tamu' => fake()->optional()->numberBetween(50, 800),
            'vendor_booking_id' => null,
            'catatan' => fake()->optional()->sentence(),
        ];
    }
}
