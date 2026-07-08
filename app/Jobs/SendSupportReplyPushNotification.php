<?php

namespace App\Jobs;

use App\Services\PushNotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Foundation\Queue\Queueable;

class SendSupportReplyPushNotification implements ShouldQueue, ShouldQueueAfterCommit
{
    use Queueable;

    public function __construct(
        public int $userId,
        public string $title,
        public string $body,
        public int $threadId,
    ) {}

    public function handle(PushNotificationService $pushNotificationService): void
    {
        $pushNotificationService->sendToUser($this->userId, [
            'title' => $this->title,
            'body' => str($this->body)->limit(120)->toString(),
            'data' => [
                'destination' => 'messages',
                'thread_id' => $this->threadId,
                'type' => 'support_reply',
            ],
        ]);
    }
}
