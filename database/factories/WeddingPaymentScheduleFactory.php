<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingPaymentSchedule>
 */
class WeddingPaymentScheduleFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'                    => User::factory(),
            'wedding_event_id'           => null,
            'source_template_id'         => null,
            'customer_payment_method_id' => null,
            'title'                      => fake()->randomElement([
                'DP Venue', 'Pelunasan Catering', 'DP Dekorasi', 'Pelunasan Foto & Video', 'DP Wedding Organizer',
            ]),
            'vendor_name' => fake()->company(),
            'category'    => fake()->randomElement(array_keys(WeddingPaymentSchedule::$categoryOptions)),
            'amount'      => fake()->numberBetween(1, 50) * 1_000_000,
            'due_date'    => fake()->dateTimeBetween('now', '+6 months'),
            'status'      => fake()->randomElement(array_keys(WeddingPaymentSchedule::$statusOptions)),
            'paid_at'     => null,
            'proof_url'   => null,
            'notes'       => fake()->optional()->sentence(),
            'sort_order'  => 0,
        ];
    }
}
