<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\VipGuest;
use Illuminate\Database\Seeder;

class VipGuestSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            VipGuest::factory()
                ->count(5)
                ->sequence(fn ($sequence) => ['no' => $sequence->index + 1])
                ->create(['user_id' => $user->id]);
        });
    }
}
