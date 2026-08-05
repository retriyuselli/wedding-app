<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingBudgetCategoryAllocationResource;
use App\Models\WeddingBudgetCategoryAllocation;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Validation\Rule;

class WeddingBudgetCategoryAllocationController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $allocations = WeddingBudgetCategoryAllocation::query()
            ->where('user_id', $request->user()->id)
            ->orderBy('category')
            ->get();

        return WeddingBudgetCategoryAllocationResource::collection($allocations);
    }

    public function store(Request $request): WeddingBudgetCategoryAllocationResource
    {
        $data = $this->validated($request);

        $allocation = $request->user()->budgetCategoryAllocations()->create($data);

        return new WeddingBudgetCategoryAllocationResource($allocation);
    }

    public function show(Request $request, int $weddingBudgetCategoryAllocation): WeddingBudgetCategoryAllocationResource
    {
        return new WeddingBudgetCategoryAllocationResource(
            $this->findOwned($request, $weddingBudgetCategoryAllocation)
        );
    }

    public function update(Request $request, int $weddingBudgetCategoryAllocation): WeddingBudgetCategoryAllocationResource
    {
        $data = $this->validated($request, isUpdate: true);

        $allocation = $this->findOwned($request, $weddingBudgetCategoryAllocation);
        $allocation->update($data);

        return new WeddingBudgetCategoryAllocationResource($allocation);
    }

    public function destroy(Request $request, int $weddingBudgetCategoryAllocation): Response
    {
        $this->findOwned($request, $weddingBudgetCategoryAllocation)->delete();

        return response()->noContent();
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request, bool $isUpdate = false): array
    {
        $categoryKeys = array_keys(WeddingPaymentSchedule::$categoryOptions);

        $categoryRules = $isUpdate
            ? ['sometimes', 'required', 'string', Rule::in($categoryKeys)]
            : ['required', 'string', Rule::in($categoryKeys)];

        $uniqueRule = Rule::unique('wedding_budget_category_allocations', 'category')
            ->where(fn ($query) => $query->where('user_id', $request->user()->id));

        if ($isUpdate) {
            $uniqueRule = $uniqueRule->ignore($request->route('weddingBudgetCategoryAllocation'));
        }

        return $request->validate([
            'category' => array_merge($categoryRules, [$uniqueRule]),
            'allocated_amount' => ['required', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string'],
        ]);
    }

    private function findOwned(Request $request, int $id): WeddingBudgetCategoryAllocation
    {
        return WeddingBudgetCategoryAllocation::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }
}
