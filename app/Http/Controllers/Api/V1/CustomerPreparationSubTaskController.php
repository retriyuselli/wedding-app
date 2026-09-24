<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CustomerPreparationSubTaskResource;
use App\Models\CustomerPreparationSubTask;
use App\Models\CustomerPreparationTask;
use App\Services\ChecklistFreeCompletionQuota;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerPreparationSubTaskController extends Controller
{
    public function __construct(
        private readonly ChecklistFreeCompletionQuota $completionQuota,
    ) {}

    public function toggle(Request $request, int $customerPreparationSubTask): JsonResponse
    {
        $subTask = $this->findOwned($request, $customerPreparationSubTask);
        $parentTask = $subTask->preparationTask()->with('subTasks')->firstOrFail();

        if ($this->wouldNewlyCompleteParent($parentTask, $subTask) && ! $this->completionQuota->allowsMarkingDone($request->user(), $parentTask)) {
            $this->completionQuota->deny();
        }

        $subTask->cycleStatus();
        $subTask->save();

        $parentTask = $subTask->preparationTask;
        $parentTask->syncStatusFromSubTasks();
        $parentTask->save();

        return response()->json([
            'data' => new CustomerPreparationSubTaskResource($subTask->fresh()),
            'parent_task_status' => $parentTask->fresh()->status,
        ]);
    }

    private function wouldNewlyCompleteParent(CustomerPreparationTask $parent, CustomerPreparationSubTask $subTask): bool
    {
        if ($parent->status === 'done') {
            return false;
        }

        $nextStatus = match ($subTask->status) {
            'pending' => 'in_progress',
            'in_progress' => 'done',
            'done' => 'pending',
            default => 'pending',
        };

        $statuses = $parent->subTasks->map(
            fn (CustomerPreparationSubTask $sibling): string => $sibling->id === $subTask->id ? $nextStatus : $sibling->status
        );

        return $statuses->isNotEmpty()
            && $statuses->every(fn (string $status): bool => $status === 'done');
    }

    private function findOwned(Request $request, int $id): CustomerPreparationSubTask
    {
        return CustomerPreparationSubTask::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }
}
