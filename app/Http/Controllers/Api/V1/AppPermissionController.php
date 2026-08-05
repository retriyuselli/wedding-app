<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Privacy\PrivacySecurityService;
use Illuminate\Http\JsonResponse;

class AppPermissionController extends Controller
{
    public function __construct(
        private PrivacySecurityService $privacySecurityService,
    ) {}

    public function index(): JsonResponse
    {
        return response()->json([
            'data' => $this->privacySecurityService->appPermissionsCatalog(),
        ]);
    }
}
