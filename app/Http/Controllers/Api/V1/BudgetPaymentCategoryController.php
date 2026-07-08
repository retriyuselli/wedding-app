<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Http\JsonResponse;

class BudgetPaymentCategoryController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => WeddingPaymentSchedule::paymentCategoriesForApi(),
            'meta' => WeddingPaymentSchedule::budgetDefaultsForApi(),
        ]);
    }
}
