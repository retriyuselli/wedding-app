<?php

namespace App\Services\Push;

use App\Contracts\PushNotificationDriver;
use App\Models\DeviceToken;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ApnsPushNotificationDriver implements PushNotificationDriver
{
    public function __construct(private ApnsJwtFactory $jwtFactory) {}

    public function send(DeviceToken $deviceToken, array $payload): bool
    {
        $bundleId = config('push.apns.bundle_id');

        if (! filled($bundleId)) {
            throw new \RuntimeException('APNS_BUNDLE_ID belum dikonfigurasi.');
        }

        $endpoint = config('push.apns.production')
            ? 'https://api.push.apple.com'
            : 'https://api.sandbox.push.apple.com';

        $notificationPayload = [
            'aps' => [
                'alert' => [
                    'title' => $payload['title'],
                    'body' => $payload['body'],
                ],
                'sound' => 'default',
            ],
        ];

        foreach ($payload['data'] ?? [] as $key => $value) {
            $notificationPayload[$key] = $value;
        }

        $response = Http::withToken($this->jwtFactory->make())
            ->withHeaders([
                'apns-topic' => $bundleId,
                'apns-push-type' => 'alert',
                'apns-priority' => '10',
            ])
            ->withOptions([
                'version' => 2.0,
            ])
            ->post("{$endpoint}/3/device/{$deviceToken->token}", $notificationPayload);

        if ($response->successful()) {
            return true;
        }

        if (in_array($response->status(), [400, 410], true)) {
            Log::warning('Menghapus device token APNs yang tidak valid.', [
                'user_id' => $deviceToken->user_id,
                'status' => $response->status(),
                'reason' => $response->body(),
            ]);

            $deviceToken->delete();

            return false;
        }

        Log::error('Gagal mengirim push notification APNs.', [
            'user_id' => $deviceToken->user_id,
            'status' => $response->status(),
            'reason' => $response->body(),
        ]);

        return false;
    }
}
