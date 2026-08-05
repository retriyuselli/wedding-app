<?php

namespace Database\Seeders;

use App\Models\TrustedDevice;
use App\Models\User;
use Illuminate\Database\Seeder;

class TrustedDeviceSeeder extends Seeder
{
    public function run(): void
    {
        User::query()->each(function (User $user): void {
            TrustedDevice::query()->updateOrCreate(
                [
                    'user_id' => $user->id,
                    'device_identifier' => 'seed-iphone-'.$user->id,
                ],
                [
                    'device_name' => 'iPhone (Seed)',
                    'platform' => 'ios',
                    'is_trusted' => true,
                    'last_used_at' => now()->subHours(2),
                    'trusted_at' => now()->subDays(3),
                    'personal_access_token_id' => null,
                ],
            );

            TrustedDevice::query()->updateOrCreate(
                [
                    'user_id' => $user->id,
                    'device_identifier' => 'seed-ipad-'.$user->id,
                ],
                [
                    'device_name' => 'iPad (Seed)',
                    'platform' => 'ios',
                    'is_trusted' => true,
                    'last_used_at' => now()->subDay(),
                    'trusted_at' => now()->subWeek(),
                    'personal_access_token_id' => null,
                ],
            );
        });
    }
}
