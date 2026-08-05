<?php

namespace App\Services;

use App\Models\CustomerPreparationTask;
use App\Models\User;

class CustomerPreparationSummaryCalculator
{
    /**
     * @return array{
     *     total: int,
     *     completed: int,
     *     in_progress: int,
     *     todo: int,
     *     progress: float
     * }
     */
    public function calculate(User $user): array
    {
        $counts = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->selectRaw('count(*) as total')
            ->selectRaw("sum(case when status = 'done' then 1 else 0 end) as completed")
            ->selectRaw("sum(case when status = 'in_progress' then 1 else 0 end) as in_progress")
            ->selectRaw("sum(case when status = 'pending' then 1 else 0 end) as todo")
            ->first();

        $total = (int) ($counts->total ?? 0);
        $completed = (int) ($counts->completed ?? 0);
        $inProgress = (int) ($counts->in_progress ?? 0);
        $todo = (int) ($counts->todo ?? 0);

        return [
            'total' => $total,
            'completed' => $completed,
            'in_progress' => $inProgress,
            'todo' => $todo,
            'progress' => $total > 0 ? round($completed / $total, 2) : 0.0,
        ];
    }
}
