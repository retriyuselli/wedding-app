<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\WeddingIncomingPayment;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeddingIncomingPayment>
 */
class WeddingIncomingPaymentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'           => User::factory(),
            'bank_name'         => fake()->randomElement(['BCA', 'Mandiri', 'BNI', 'BRI']),
            'amount'            => fake()->numberBetween(1, 20) * 1_000_000,
            'transfer_date'     => fake()->dateTimeBetween('-3 months', 'now'),
            'sender_name'       => fake()->name(),
            'description'       => fake()->optional()->sentence(),
            'reference_number'  => fake()->numerify('TRX-########'),
            'proof_url'         => null,
            'status'            => fake()->randomElement(array_keys(WeddingIncomingPayment::$statusOptions)),
            'confirmed_at'      => null,
            'confirmed_by'      => null,
            'rejection_reason'  => null,
            'notes'             => fake()->optional()->sentence(),
        ];
    }
}
