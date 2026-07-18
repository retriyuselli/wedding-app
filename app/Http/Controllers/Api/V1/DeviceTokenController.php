<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\DeviceTokenResource;
use App\Models\DeviceToken;
use App\Models\User;
use App\Services\BroadcastCustomerNotificationService;
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
        abort_unless($user->isSuperAdmin(), 403);

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

    public function sendNotification(
        Request $request,
        BroadcastCustomerNotificationService $broadcastService,
    ): JsonResponse {
        /** @var User $sender */
        $sender = $request->user();
        abort_unless($sender->isSuperAdmin(), 403);

        $data = $request->validate([
            'send_to_all' => ['required', 'boolean'],
            'email' => ['nullable', 'required_if:send_to_all,false', 'email', 'exists:users,email'],
            'title' => ['required', 'string', 'max:120'],
            'message' => ['required', 'string', 'max:1000'],
        ]);

        $payload = [
            'group' => 'system',
            'title' => $data['title'],
            'message' => $data['message'],
            'icon' => 'bell.fill',
            'destination' => null,
            'tint' => 'info',
            'is_unread' => true,
        ];

        if ($data['send_to_all']) {
            $result = $broadcastService->sendToAllUsers($payload);

            return response()->json([
                'data' => [
                    'recipient_count' => $result['count'],
                    'push_sent' => $result['push_sent'],
                ],
                'message' => "Notifikasi dikirim ke {$result['count']} user.",
            ]);
        }

        $recipient = User::query()->where('email', $data['email'])->firstOrFail();
        $result = $broadcastService->sendToUser($recipient, $payload);

        return response()->json([
            'data' => [
                'recipient_count' => 1,
                'push_sent' => $result['push_sent'],
            ],
            'message' => "Notifikasi dikirim ke {$recipient->email}.",
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
