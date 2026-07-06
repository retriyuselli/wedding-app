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
        User::all()->each(function (User $user): void {
            WeddingInfo::factory()->create([
                'user_id' => $user->id,
            ]);
        });
    }
}
