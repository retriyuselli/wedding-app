<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\WeddingBudget;
use Illuminate\Database\Seeder;

class WeddingBudgetSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            WeddingBudget::factory()->create([
                'user_id' => $user->id,
            ]);
        });
    }
}
