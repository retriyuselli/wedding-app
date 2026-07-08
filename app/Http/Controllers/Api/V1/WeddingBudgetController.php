<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingBudgetResource;
use App\Models\WeddingBudget;
use App\Services\WeddingBudgetSummaryCalculator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WeddingBudgetController extends Controller
{
    public function __construct(
        private readonly WeddingBudgetSummaryCalculator $summaryCalculator,
    ) {}

    public function show(Request $request): WeddingBudgetResource
    {
        return new WeddingBudgetResource($request->user()->weddingBudget);
    }

    public function summary(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->summaryCalculator->calculate($request->user()),
        ]);
    }

    public function update(Request $request): WeddingBudgetResource
    {
        $data = $request->validate([
            'total_budget' => ['required', 'numeric', 'min:0'],
            'currency' => ['nullable', 'string', 'max:10'],
            'notes' => ['nullable', 'string'],
        ]);

        $budget = $request->user()->weddingBudget()->updateOrCreate(
            ['user_id' => $request->user()->id],
            [
                'total_budget' => $data['total_budget'],
                'currency' => $data['currency'] ?? WeddingBudget::defaultCurrency(),
                'notes' => $data['notes'] ?? null,
            ]
        );

        return new WeddingBudgetResource($budget);
    }
}
