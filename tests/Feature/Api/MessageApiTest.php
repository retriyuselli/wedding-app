<?php

namespace Tests\Feature\Api;

use App\Models\Message;
use App\Models\MessageThread;
use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MessageApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_threads_returns_owned_threads_with_unread_counts(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $otherUser = User::factory()->create();

        $thread = MessageThread::factory()->for($user)->create([
            'name' => 'Grand Ballroom',
            'category' => 'vendor',
        ]);

        Message::factory()->for($thread, 'thread')->for($user)->outgoing()->create([
            'body' => 'Halo, apakah venue tersedia?',
            'created_at' => now()->subMinutes(30),
        ]);
        Message::factory()->for($thread, 'thread')->for($user)->incomingUnread()->create([
            'body' => 'Venue masih tersedia.',
            'created_at' => now()->subMinutes(20),
        ]);
        Message::factory()->for($thread, 'thread')->for($user)->incomingUnread()->create([
            'body' => 'Kami konfirmasi jadwal survey besok.',
            'created_at' => now()->subMinutes(10),
        ]);

        MessageThread::factory()->for($otherUser)->create();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/messages/threads');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Grand Ballroom')
            ->assertJsonPath('data.0.category', 'vendor')
            ->assertJsonPath('data.0.unread_count', 2)
            ->assertJsonPath('data.0.has_unread', true)
            ->assertJsonPath('data.0.last_message', 'Kami konfirmasi jadwal survey besok.');
    }

    public function test_show_thread_marks_incoming_messages_as_read(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $thread = MessageThread::factory()->for($user)->create();
        $unread = Message::factory()->for($thread, 'thread')->for($user)->incomingUnread()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/messages/threads/'.$thread->id);

        $response
            ->assertOk()
            ->assertJsonPath('data.id', $thread->id)
            ->assertJsonCount(1, 'data.messages');

        $this->assertNotNull($unread->fresh()->read_at);
    }

    public function test_send_message_creates_outgoing_message(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $thread = MessageThread::factory()->for($user)->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/messages/threads/'.$thread->id.'/send', [
                'body' => 'Terima kasih infonya.',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.body', 'Terima kasih infonya.')
            ->assertJsonPath('data.is_outgoing', true)
            ->assertJsonPath('data.topic', null);

        $this->assertDatabaseHas('messages', [
            'message_thread_id' => $thread->id,
            'body' => 'Terima kasih infonya.',
            'is_outgoing' => true,
        ]);
    }

    public function test_support_thread_endpoint_returns_existing_thread(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $thread = MessageThread::factory()->for($user)->create([
            'name' => 'Support Wedding App',
            'category' => 'support',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/messages/threads/support');

        $response
            ->assertOk()
            ->assertJsonPath('data.id', $thread->id)
            ->assertJsonPath('data.category', 'support')
            ->assertJsonPath('data.name', 'Support Wedding App');
    }

    public function test_support_thread_endpoint_creates_thread_when_missing(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/messages/threads/support');

        $response
            ->assertOk()
            ->assertJsonPath('data.category', 'support')
            ->assertJsonPath('data.name', 'Support Wedding App');

        $this->assertDatabaseHas('message_threads', [
            'user_id' => $user->id,
            'category' => 'support',
            'name' => 'Support Wedding App',
        ]);
    }

    public function test_send_support_message_stores_topic(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/messages/threads/'.$thread->id.'/send', [
                'body' => 'Saya tidak bisa login.',
                'topic' => 'account',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.body', 'Saya tidak bisa login.')
            ->assertJsonPath('data.topic', 'account');

        $this->assertDatabaseHas('messages', [
            'message_thread_id' => $thread->id,
            'body' => 'Saya tidak bisa login.',
            'topic' => 'account',
        ]);
    }

    public function test_send_support_message_rejects_invalid_topic(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $thread = MessageThread::factory()->for($user)->create([
            'category' => 'support',
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/messages/threads/'.$thread->id.'/send', [
                'body' => 'Pertanyaan umum.',
                'topic' => 'invalid-topic',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['topic']);
    }

    public function test_user_cannot_access_other_users_thread(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $thread = MessageThread::factory()->for(User::factory())->create();

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/messages/threads/'.$thread->id)
            ->assertNotFound();
    }
}
