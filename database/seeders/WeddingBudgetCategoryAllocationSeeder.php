<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\WeddingBudget;
use App\Models\WeddingBudgetCategoryAllocation;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Database\Seeder;

class WeddingBudgetCategoryAllocationSeeder extends Seeder
{
    /**
     * Default share of total budget per category (must sum to ~1.0).
     *
     * @var array<string, float>
     */
    private const SHARES = [
        'venue' => 0.25,
        'catering' => 0.22,
        'decoration' => 0.12,
        'photo_video' => 0.10,
        'entertainment' => 0.06,
        'makeup' => 0.08,
        'transport' => 0.04,
        'wo' => 0.08,
        'other' => 0.05,
    ];

    public function run(): void
    {
        User::query()->each(function (User $user): void {
            $budget = WeddingBudget::query()->where('user_id', $user->id)->first();
            $total = (float) ($budget?->total_budget ?? 250_000_000);

            foreach (array_keys(WeddingPaymentSchedule::$categoryOptions) as $category) {
                $share = self::SHARES[$category] ?? 0.05;
                $amount = (int) round($total * $share);

                WeddingBudgetCategoryAllocation::query()->updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'category' => $category,
                    ],
                    [
                        'allocated_amount' => $amount,
                        'notes' => WeddingPaymentSchedule::categoryDescription($category),
                    ],
                );
            }
        });
    }
}
