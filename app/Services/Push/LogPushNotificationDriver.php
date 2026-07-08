<?php

namespace App\Services\Push;

use App\Contracts\PushNotificationDriver;
use App\Models\DeviceToken;
use Illuminate\Support\Facades\Log;

class LogPushNotificationDriver implements PushNotificationDriver
{
    public function send(DeviceToken $deviceToken, array $payload): bool
    {
        Log::info('Push notification dispatched.', [
            'user_id' => $deviceToken->user_id,
            'platform' => $deviceToken->platform,
            'token' => substr($deviceToken->token, 0, 12).'...',
            'title' => $payload['title'],
            'body' => $payload['body'],
            'data' => $payload['data'] ?? [],
        ]);

        return true;
    }
}
