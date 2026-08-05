<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CustomerPreparationSubTaskResource;
use App\Models\CustomerPreparationSubTask;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerPreparationSubTaskController extends Controller
{
    public function toggle(Request $request, int $customerPreparationSubTask): JsonResponse
    {
        $subTask = $this->findOwned($request, $customerPreparationSubTask);
        $subTask->cycleStatus();
        $subTask->save();

        $parentTask = $subTask->preparationTask;
        $parentTask->syncStatusFromSubTasks();
        $parentTask->save();

        return response()->json([
            'data'               => new CustomerPreparationSubTaskResource($subTask->fresh()),
            'parent_task_status' => $parentTask->fresh()->status,
        ]);
    }

    private function findOwned(Request $request, int $id): CustomerPreparationSubTask
    {
        return CustomerPreparationSubTask::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }
}
