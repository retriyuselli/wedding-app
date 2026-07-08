<?php

namespace App\Services;

use App\Contracts\PushNotificationDriver;
use App\Models\User;
use App\Services\Push\ApnsPushNotificationDriver;
use App\Services\Push\LogPushNotificationDriver;

class PushNotificationService
{
    public function __construct(private PushNotificationDriver $driver) {}

    /**
     * @param  array{title: string, body: string, data?: array<string, mixed>}  $payload
     */
    public function sendToUser(User|int $user, array $payload): int
    {
        $userModel = $user instanceof User ? $user : User::query()->find($user);

        if (! $userModel || ! $this->pushEnabledFor($userModel)) {
            return 0;
        }

        $tokens = $userModel->deviceTokens()->get();

        $sentCount = 0;

        foreach ($tokens as $deviceToken) {
            if ($this->driver->send($deviceToken, $payload)) {
                $deviceToken->update(['last_used_at' => now()]);
                $sentCount++;
            }
        }

        return $sentCount;
    }

    private function pushEnabledFor(User $user): bool
    {
        $settings = $user->notification_settings ?? [];

        if (! array_key_exists('push', $settings)) {
            return true;
        }

        return (bool) $settings['push'];
    }

    public static function resolveDriver(): PushNotificationDriver
    {
        return match (config('push.driver')) {
            'apns' => app(ApnsPushNotificationDriver::class),
            default => app(LogPushNotificationDriver::class),
        };
    }
}
