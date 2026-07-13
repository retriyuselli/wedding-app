<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Privacy\PrivacySecurityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PrivacySecurityController extends Controller
{
    public function __construct(
        private PrivacySecurityService $privacySecurityService,
    ) {}

    public function summary(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->privacySecurityService->summary($request->user()),
        ]);
    }

    public function visibility(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->privacySecurityService->visibility($request->user()),
        ]);
    }

    public function updateVisibility(Request $request): JsonResponse
    {
        $data = $request->validate([
            'profile_visibility' => ['sometimes', 'string', 'in:private,couple,public'],
            'wedding_visibility' => ['sometimes', 'string', 'in:private,couple,vendors'],
            'guest_list_visibility' => ['sometimes', 'string', 'in:private,couple'],
            'budget_visibility' => ['sometimes', 'string', 'in:private,couple'],
            'show_in_directory' => ['sometimes', 'boolean'],
            'allow_vendor_contact' => ['sometimes', 'boolean'],
        ]);

        return response()->json([
            'data' => $this->privacySecurityService->updateVisibility($request->user(), $data),
            'message' => 'Pengaturan visibilitas berhasil disimpan.',
        ]);
    }
}
