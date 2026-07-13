<?php

namespace Database\Factories;

use App\Models\TrustedDevice;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<TrustedDevice>
 */
class TrustedDeviceFactory extends Factory
{
    protected $model = TrustedDevice::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'device_name' => fake()->randomElement(['iPhone 15', 'iPhone 14', 'iPad Pro']),
            'device_identifier' => (string) Str::uuid(),
            'platform' => 'ios',
            'is_trusted' => true,
            'last_used_at' => now(),
            'trusted_at' => now(),
            'personal_access_token_id' => null,
        ];
    }
}
