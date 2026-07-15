<?php

namespace App\Services;

use App\Contracts\PushNotificationDriver;
use App\Models\User;
use App\Services\Push\ApnsPushNotificationDriver;
use App\Services\Push\LogPushNotificationDriver;
use App\Support\UserSettings;

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
        $settings = UserSettings::forUser($user);

        return (bool) ($settings['push_notifications'] ?? true);
    }

    public static function resolveDriver(): PushNotificationDriver
    {
        return match (config('push.driver')) {
            'apns' => app(ApnsPushNotificationDriver::class),
            default => app(LogPushNotificationDriver::class),
        };
    }
}
