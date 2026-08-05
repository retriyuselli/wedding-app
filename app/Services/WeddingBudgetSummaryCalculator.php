<?php

namespace App\Services;

use App\Models\User;

class WeddingBudgetSummaryCalculator
{
    /**
     * @return array{
     *     total_budget: float,
     *     spent: float,
     *     commitment: float,
     *     remaining: float,
     *     spent_percent: int,
     *     commitment_percent: int,
     *     remaining_percent: int,
     *     planned_allocation_total: float,
     *     plan_coverage_percent: int|null,
     *     incoming_total: float,
     *     incoming_confirmed_total: float,
     *     incoming_pending_count: int,
     * }
     */
    public function calculate(User $user): array
    {
        $schedules = $user->paymentSchedules()->get(['amount', 'status']);
        $allocations = $user->budgetCategoryAllocations()->get(['allocated_amount']);
        $budget = $user->weddingBudget;
        $incomingPayments = $user->incomingPayments()->get(['amount', 'status']);

        $spent = (float) $schedules->where('status', 'paid')->sum('amount');
        $commitment = (float) $schedules->whereIn('status', ['pending', 'overdue'])->sum('amount');
        $plannedAllocationTotal = (float) $allocations->sum('allocated_amount');
        $totalRecorded = $spent + $commitment;

        $configuredBudget = (float) ($budget?->total_budget ?? 0);
        $totalBudget = $configuredBudget;

        if ($totalBudget <= 0) {
            $totalBudget = $plannedAllocationTotal > 0 ? $plannedAllocationTotal : $totalRecorded;
        }

        $remaining = max($totalBudget - $spent - $commitment, 0);

        $percent = static function (float $value, float $base): int {
            if ($base <= 0) {
                return 0;
            }

            return (int) round(($value / $base) * 100);
        };

        $planCoveragePercent = null;

        if ($configuredBudget > 0 && $plannedAllocationTotal > 0) {
            $planCoveragePercent = (int) min(100, round(($plannedAllocationTotal / $configuredBudget) * 100));
        }

        $incomingTotal = (float) $incomingPayments->sum('amount');
        $incomingConfirmedTotal = (float) $incomingPayments->where('status', 'confirmed')->sum('amount');
        $incomingPendingCount = $incomingPayments->where('status', config('wedding.default_incoming_payment_status', 'menunggu'))->count();

        return [
            'total_budget' => $totalBudget,
            'spent' => $spent,
            'commitment' => $commitment,
            'remaining' => $remaining,
            'spent_percent' => $percent($spent, $totalBudget),
            'commitment_percent' => $percent($commitment, $totalBudget),
            'remaining_percent' => $percent($remaining, $totalBudget),
            'planned_allocation_total' => $plannedAllocationTotal,
            'plan_coverage_percent' => $planCoveragePercent,
            'incoming_total' => $incomingTotal,
            'incoming_confirmed_total' => $incomingConfirmedTotal,
            'incoming_pending_count' => $incomingPendingCount,
        ];
    }
}
