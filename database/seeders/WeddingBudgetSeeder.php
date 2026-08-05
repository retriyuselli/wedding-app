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
        User::query()->each(function (User $user): void {
            if (WeddingBudget::query()->where('user_id', $user->id)->exists()) {
                return;
            }

            WeddingBudget::factory()->create([
                'user_id' => $user->id,
                'total_budget' => 250_000_000,
                'notes' => 'Total anggaran seed untuk pengembangan iOS',
            ]);
        });
    }
}
