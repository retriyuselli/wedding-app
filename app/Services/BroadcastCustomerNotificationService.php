<?php

namespace App\Services;

use App\Models\CustomerNotification;
use App\Models\User;
use InvalidArgumentException;

class BroadcastCustomerNotificationService
{
    public function __construct(
        private PushNotificationService $pushNotificationService,
    ) {}

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
     * @return array{count: int, first: CustomerNotification, push_sent: int}
     */
    public function sendToAllUsers(array $payload): array
    {
        $count = 0;
        $pushSent = 0;
        $first = null;

        User::query()
            ->orderBy('id')
            ->chunkById(200, function ($users) use ($payload, &$count, &$first, &$pushSent): void {
                foreach ($users as $user) {
                    $result = $this->sendToUser($user, $payload);
                    $notification = $result['notification'];

                    $first ??= $notification;
                    $pushSent += $result['push_sent'];
                    $count++;
                }
            });

        if ($first === null || $count === 0) {
            throw new InvalidArgumentException('Tidak ada user yang dapat menerima notifikasi.');
        }

        return [
            'count' => $count,
            'first' => $first,
            'push_sent' => $pushSent,
        ];
    }

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
     * @return array{notification: CustomerNotification, push_sent: int}
     */
    public function sendToUser(User|int $user, array $payload): array
    {
        $recipient = $user instanceof User ? $user : User::query()->findOrFail($user);

        $notification = CustomerNotification::query()->create([
            ...$payload,
            'user_id' => $recipient->id,
        ]);

        $data = ['type' => 'admin_notification'];
        if (filled($payload['destination'] ?? null)) {
            $data['destination'] = $payload['destination'];
        }

        $pushSent = $this->pushNotificationService->sendToUser($recipient, [
            'title' => $payload['title'],
            'body' => filled($payload['message'] ?? null)
                ? $payload['message']
                : $payload['title'],
            'data' => $data,
        ]);

        return [
            'notification' => $notification,
            'push_sent' => $pushSent,
        ];
    }
}
