<?php

namespace App\Services;

use App\Jobs\SendSupportReplyPushNotification;
use App\Models\CustomerNotification;
use App\Models\Message;
use App\Models\MessageThread;
use App\Models\User;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Facades\Auth;
use InvalidArgumentException;

class SupportMessageReplyService
{
    public function reply(MessageThread $thread, string $body): Message
    {
        $actor = Auth::user();

        if (! $actor instanceof User || ! $actor->isSuperAdmin()) {
            throw new AuthorizationException('Hanya super admin yang dapat mengirim balasan support dan notifikasi.');
        }

        if ($thread->category !== 'support') {
            throw new InvalidArgumentException('Balasan admin hanya dapat dikirim pada thread support.');
        }

        $message = $thread->messages()->create([
            'user_id' => $thread->user_id,
            'body' => $body,
            'is_outgoing' => false,
            'read_at' => null,
        ]);

        $thread->touch();

        CustomerNotification::create([
            'user_id' => $thread->user_id,
            'group' => 'system',
            'title' => 'Balasan dari Support',
            'message' => str($body)->limit(120)->toString(),
            'icon' => 'bubble.left.and.bubble.right.fill',
            'destination' => 'messages',
            'tint' => 'info',
            'is_unread' => true,
        ]);

        SendSupportReplyPushNotification::dispatch(
            $thread->user_id,
            'Balasan dari Support',
            $body,
            $thread->id,
        );

        return $message;
    }
}
