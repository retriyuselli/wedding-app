<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\WeddingInfo;
use Illuminate\Database\Seeder;

class WeddingInfoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::query()->each(function (User $user): void {
            if (WeddingInfo::query()->where('user_id', $user->id)->exists()) {
                return;
            }

            WeddingInfo::factory()->create([
                'user_id' => $user->id,
            ]);
        });
    }
}
