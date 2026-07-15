<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\DeviceTokenResource;
use App\Models\DeviceToken;
use App\Services\PushNotificationService;
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

    public function sendTest(Request $request, PushNotificationService $pushNotificationService): JsonResponse
    {
        $user = $request->user();
        $tokenCount = $user->deviceTokens()->count();

        if ($tokenCount === 0) {
            return response()->json([
                'message' => 'Device token belum terdaftar. Izinkan notifikasi di iPhone lalu buka ulang aplikasi.',
            ], 422);
        }

        $sent = $pushNotificationService->sendToUser($user, [
            'title' => 'Tes Notifikasi Wedding App',
            'body' => 'Banner push berhasil. Tap untuk membuka pesan.',
            'data' => [
                'destination' => 'messages',
                'type' => 'test',
            ],
        ]);

        return response()->json([
            'data' => [
                'sent' => $sent,
                'token_count' => $tokenCount,
            ],
        ]);
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
