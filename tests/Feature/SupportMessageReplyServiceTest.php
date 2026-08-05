<?php

namespace Tests\Feature;

use App\Contracts\PushNotificationDriver;
use App\Jobs\SendSupportReplyPushNotification;
use App\Models\DeviceToken;
use App\Models\Message;
use App\Models\MessageThread;
use App\Models\User;
use App\Services\Push\LogPushNotificationDriver;
use App\Services\PushNotificationService;
use App\Services\SupportMessageReplyService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Queue;
use InvalidArgumentException;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class SupportMessageReplyServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_reply_creates_incoming_message_for_user(): void
    {
        Queue::fake();

        $admin = $this->actingAsSuperAdmin();
        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
            'name' => 'Support Wedding App',
        ]);

        $message = app(SupportMessageReplyService::class)->reply(
            $thread,
            'Halo, kami sudah cek akun Anda.',
        );

        $this->assertInstanceOf(Message::class, $message);
        $this->assertDatabaseHas('messages', [
            'id' => $message->id,
            'message_thread_id' => $thread->id,
            'user_id' => $user->id,
            'body' => 'Halo, kami sudah cek akun Anda.',
            'is_outgoing' => false,
        ]);
        $this->assertNull($message->read_at);
        $this->assertTrue($admin->isSuperAdmin());
    }

    public function test_reply_creates_customer_notification(): void
    {
        Queue::fake();

        $this->actingAsSuperAdmin();
        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
        ]);

        app(SupportMessageReplyService::class)->reply(
            $thread,
            'Tim support akan membantu Anda segera.',
        );

        $this->assertDatabaseHas('customer_notifications', [
            'user_id' => $user->id,
            'group' => 'system',
            'title' => 'Balasan dari Support',
            'destination' => 'messages',
            'is_unread' => true,
        ]);
    }

    public function test_reply_dispatches_push_notification_job(): void
    {
        Queue::fake();

        $this->actingAsSuperAdmin();
        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
        ]);

        app(SupportMessageReplyService::class)->reply($thread, 'Balasan support.');

        Queue::assertPushed(SendSupportReplyPushNotification::class, function (SendSupportReplyPushNotification $job) use ($user, $thread): bool {
            return $job->userId === $user->id
                && $job->threadId === $thread->id
                && $job->title === 'Balasan dari Support';
        });
    }

    public function test_reply_updates_thread_timestamp(): void
    {
        Queue::fake();

        $this->actingAsSuperAdmin();
        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
            'updated_at' => now()->subDay(),
        ]);

        $previousUpdatedAt = $thread->updated_at;

        app(SupportMessageReplyService::class)->reply($thread, 'Baik, terima kasih.');

        $this->assertTrue($thread->fresh()->updated_at->greaterThan($previousUpdatedAt));
    }

    public function test_reply_rejects_non_support_thread(): void
    {
        Queue::fake();

        $this->actingAsSuperAdmin();
        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'vendor',
        ]);

        $this->expectException(InvalidArgumentException::class);

        app(SupportMessageReplyService::class)->reply($thread, 'Test');
    }

    public function test_non_super_admin_cannot_reply(): void
    {
        Queue::fake();

        $staff = User::factory()->create();
        $this->actingAs($staff);

        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
        ]);

        $this->expectException(AuthorizationException::class);

        app(SupportMessageReplyService::class)->reply($thread, 'Balasan tidak diizinkan.');

        $this->assertDatabaseMissing('messages', [
            'message_thread_id' => $thread->id,
            'body' => 'Balasan tidak diizinkan.',
        ]);
        $this->assertDatabaseMissing('customer_notifications', [
            'user_id' => $user->id,
            'title' => 'Balasan dari Support',
        ]);
    }

    public function test_guest_cannot_reply_without_authentication(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
        ]);

        $this->expectException(AuthorizationException::class);

        app(SupportMessageReplyService::class)->reply($thread, 'Tanpa login.');
    }

    public function test_user_sees_unread_count_after_admin_reply(): void
    {
        Queue::fake();

        $this->actingAsSuperAdmin();
        $user = User::factory()->create();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
        ]);

        app(SupportMessageReplyService::class)->reply($thread, 'Balasan support.');

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/messages/threads');

        $response
            ->assertOk()
            ->assertJsonPath('data.0.unread_count', 1)
            ->assertJsonPath('data.0.has_unread', true);
    }

    public function test_push_notification_job_sends_to_registered_device_tokens(): void
    {
        Log::spy();
        config(['push.driver' => 'log']);
        $this->app->instance(PushNotificationDriver::class, app(LogPushNotificationDriver::class));

        $user = User::factory()->create();
        DeviceToken::factory()->for($user)->create([
            'token' => 'ios-token-abc',
        ]);

        $job = new SendSupportReplyPushNotification(
            $user->id,
            'Balasan dari Support',
            'Halo, kami sudah membantu akun Anda.',
            10,
        );

        $job->handle(app(PushNotificationService::class));

        Log::shouldHaveReceived('info')
            ->once()
            ->withArgs(function (string $message, array $context): bool {
                return $message === 'Push notification dispatched.'
                    && $context['title'] === 'Balasan dari Support';
            });
    }

    private function actingAsSuperAdmin(): User
    {
        Role::findOrCreate(config('filament-shield.super_admin.name', 'super_admin'), 'web');

        $admin = User::factory()->create();
        $admin->assignRole(config('filament-shield.super_admin.name', 'super_admin'));

        $this->actingAs($admin);

        return $admin;
    }
}
