<?php

namespace App\Services;

use App\Models\CustomerPreparationTask;
use App\Models\User;

class ChecklistFreeCompletionQuota
{
    public function limit(): int
    {
        return max(0, (int) config('billing.free_checklist_done_limit', 20));
    }

    public function allowsMarkingDone(User $user, CustomerPreparationTask $task): bool
    {
        if ($user->isPremium() || $task->status === 'done') {
            return true;
        }

        return $this->doneCount($user, exceptTaskId: $task->id) < $this->limit();
    }

    public function allowsCreatingDoneTask(User $user): bool
    {
        if ($user->isPremium()) {
            return true;
        }

        return $this->doneCount($user) < $this->limit();
    }

    public function deny(): never
    {
        abort(response()->json([
            'message' => config('billing.checklist_free_limit_message'),
            'code' => 'checklist_free_limit',
        ], 403));
    }

    private function doneCount(User $user, ?int $exceptTaskId = null): int
    {
        $query = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->where('status', 'done');

        if ($exceptTaskId !== null) {
            $query->whereKeyNot($exceptTaskId);
        }

        return $query->count();
    }
}
