<?php

namespace Tests\Feature;

use App\Models\Message;
use App\Models\MessageThread;
use App\Models\User;
use Database\Seeders\MessageThreadSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MessagePageTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $this->seed(MessageThreadSeeder::class);
    }

    public function test_messages_page_shows_redesigned_layout(): void
    {
        $response = $this->actingAs($this->user)->get(route('messages'));

        $response->assertOk();
        $response->assertSee('Kelola percakapan dengan vendor dan tim pernikahan Anda');
        $response->assertSee('Semua');
        $response->assertSee('Belum Dibaca');
        $response->assertSee('Favorit');
        $response->assertSee('Grand Ballroom');
        $response->assertSee('Informasi Vendor');
        $response->assertSee('messages-shell', false);
    }

    public function test_unread_tab_filters_threads(): void
    {
        $response = $this->actingAs($this->user)->get(route('messages', ['tab' => 'unread']));

        $response->assertOk();
        $response->assertSee('Grand Ballroom');
        $response->assertSee('Panitia Akad');
        $response->assertDontSee('Support Wedding App');
    }

    public function test_sending_message_persists_and_redirects(): void
    {
        $thread = MessageThread::query()->where('user_id', $this->user->id)->firstOrFail();

        $this->actingAs($this->user)
            ->post(route('messages.send', $thread), ['body' => 'Pesan uji coba'])
            ->assertRedirect(route('messages', ['thread' => $thread->id, 'tab' => 'all']));

        $this->assertDatabaseHas(Message::class, [
            'message_thread_id' => $thread->id,
            'user_id' => $this->user->id,
            'body' => 'Pesan uji coba',
            'is_outgoing' => true,
        ]);
    }

    public function test_favorite_toggle_stores_in_session(): void
    {
        $thread = MessageThread::query()->where('user_id', $this->user->id)->firstOrFail();

        $this->actingAs($this->user)
            ->post(route('messages.favorite', $thread))
            ->assertRedirect();

        $this->assertContains($thread->id, session('favorite_threads'));
    }

    public function test_viewing_thread_marks_incoming_messages_as_read(): void
    {
        $thread = MessageThread::query()
            ->where('user_id', $this->user->id)
            ->where('name', 'Grand Ballroom')
            ->firstOrFail();

        $this->assertTrue(
            Message::query()
                ->where('message_thread_id', $thread->id)
                ->where('is_outgoing', false)
                ->whereNull('read_at')
                ->exists()
        );

        $this->actingAs($this->user)
            ->get(route('messages', ['thread' => $thread->id]))
            ->assertOk();

        $this->assertFalse(
            Message::query()
                ->where('message_thread_id', $thread->id)
                ->where('is_outgoing', false)
                ->whereNull('read_at')
                ->exists()
        );
    }
}
