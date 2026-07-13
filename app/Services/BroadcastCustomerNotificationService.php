<?php

namespace App\Services;

use App\Models\CustomerNotification;
use App\Models\User;
use InvalidArgumentException;

class BroadcastCustomerNotificationService
{
    /**
     * @param  array{
     *     title: string,
     *     message?: string|null,
     *     group?: string|null,
     *     icon?: string|null,
     *     destination?: string|null,
     *     tint?: string|null,
     *     is_unread?: bool
     * }  $payload
     * @return array{count: int, first: CustomerNotification}
     */
    public function sendToAllUsers(array $payload): array
    {
        $count = 0;
        $first = null;

        User::query()
            ->orderBy('id')
            ->chunkById(200, function ($users) use ($payload, &$count, &$first): void {
                foreach ($users as $user) {
                    $notification = CustomerNotification::query()->create([
                        ...$payload,
                        'user_id' => $user->id,
                    ]);

                    $first ??= $notification;
                    $count++;
                }
            });

        if ($first === null || $count === 0) {
            throw new InvalidArgumentException('Tidak ada user yang dapat menerima notifikasi.');
        }

        return [
            'count' => $count,
            'first' => $first,
        ];
    }
}
