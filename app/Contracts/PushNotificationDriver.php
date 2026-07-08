<?php

namespace App\Contracts;

use App\Models\DeviceToken;

interface PushNotificationDriver
{
    /**
     * @param  array{title: string, body: string, data?: array<string, mixed>}  $payload
     */
    public function send(DeviceToken $deviceToken, array $payload): bool;
}
