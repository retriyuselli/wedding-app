<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CustomerPreparationTaskResource;
use App\Models\CustomerPreparationTask;
use App\Services\CustomerPreparationSummaryCalculator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class CustomerPreparationTaskController extends Controller
{
    public function __construct(
        private readonly CustomerPreparationSummaryCalculator $summaryCalculator,
    ) {}

    public function summary(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->summaryCalculator->calculate($request->user()),
        ]);
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        $query = CustomerPreparationTask::query()
            ->where('user_id', $request->user()->id)
            ->with(['subTasks', 'attachments']);

        if ($request->filled('wedding_event_id')) {
            $query->where('wedding_event_id', $request->integer('wedding_event_id'));
        }

        if ($request->filled('section_id')) {
            $query->where('section_id', $request->integer('section_id'));
        }

        return CustomerPreparationTaskResource::collection($query->orderBy('sort_order')->get());
    }

    public function store(Request $request): CustomerPreparationTaskResource
    {
        $data = $this->validated($request);
        $data['status'] ??= 'pending';
        $data['priority'] ??= 'medium';
        $data['user_id'] = $request->user()->id;

        if (! array_key_exists('sort_order', $data) || $data['sort_order'] === null) {
            unset($data['sort_order']);
        }

        $task = CustomerPreparationTask::create($data);

        return new CustomerPreparationTaskResource($task->load(['subTasks', 'attachments']));
    }

    public function show(Request $request, int $customerPreparationTask): CustomerPreparationTaskResource
    {
        return new CustomerPreparationTaskResource(
            $this->findOwned($request, $customerPreparationTask)->load(['subTasks', 'attachments'])
        );
    }

    public function update(Request $request, int $customerPreparationTask): CustomerPreparationTaskResource
    {
        $data = $this->validated($request, isUpdate: true);

        $task = $this->findOwned($request, $customerPreparationTask);
        $task->update($data);

        return new CustomerPreparationTaskResource($task->load(['subTasks', 'attachments']));
    }

    public function destroy(Request $request, int $customerPreparationTask): Response
    {
        $this->findOwned($request, $customerPreparationTask)->delete();

        return response()->noContent();
    }

    public function toggle(Request $request, int $customerPreparationTask): CustomerPreparationTaskResource
    {
        $task = $this->findOwned($request, $customerPreparationTask);
        $task->status = $task->status === 'done' ? 'pending' : 'done';
        $task->save();

        return new CustomerPreparationTaskResource($task->load(['subTasks', 'attachments']));
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request, bool $isUpdate = false): array
    {
        $userId = $request->user()->id;

        return $request->validate([
            'title' => [$isUpdate ? 'sometimes' : 'required', 'string', 'max:255'],
            'label' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
            'priority' => ['nullable', 'string', 'in:'.implode(',', array_keys(CustomerPreparationTask::$priorityOptions))],
            'status' => ['nullable', 'string', 'in:'.implode(',', array_keys(CustomerPreparationTask::$statusOptions))],
            'due_date' => ['nullable', 'date'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'wedding_event_id' => ['nullable', 'integer', 'exists:wedding_events,id,user_id,'.$userId],
            'section_id' => ['nullable', 'integer', 'exists:customer_preparation_sections,id,user_id,'.$userId],
        ]);
    }

    private function findOwned(Request $request, int $id): CustomerPreparationTask
    {
        return CustomerPreparationTask::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
