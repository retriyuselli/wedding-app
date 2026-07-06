<?php

namespace Database\Factories;

use App\Models\CustomerPaymentMethod;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CustomerPaymentMethod>
 */
class CustomerPaymentMethodFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id'        => User::factory(),
            'name'           => fake()->randomElement(['BCA', 'Mandiri', 'BNI', 'BRI', 'GoPay', 'OVO']),
            'logo_icon'      => null,
            'account_number' => fake()->numerify('##########'),
            'account_name'   => fake()->name(),
            'is_primary'     => false,
            'type'           => fake()->randomElement(['bank', 'e-wallet']),
        ];
    }
}
