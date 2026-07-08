<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\DeviceTokenResource;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class DeviceTokenController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:512'],
            'platform' => ['required', 'string', 'in:ios,android'],
            'device_name' => ['nullable', 'string', 'max:255'],
        ]);

        $deviceToken = DeviceToken::query()->updateOrCreate(
            ['token' => $data['token']],
            [
                'user_id' => $request->user()->id,
                'platform' => $data['platform'],
                'device_name' => $data['device_name'] ?? $request->user()->currentAccessToken()?->name,
                'last_used_at' => now(),
            ],
        );

        return response()->json([
            'data' => new DeviceTokenResource($deviceToken),
        ], $deviceToken->wasRecentlyCreated ? 201 : 200);
    }

    public function destroy(Request $request): Response
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:512'],
        ]);

        $request->user()
            ->deviceTokens()
            ->where('token', $data['token'])
            ->delete();

        return response()->noContent();
    }
}
