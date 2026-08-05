<?php

namespace Tests\Feature;

use App\Models\Inspiration;
use App\Models\User;
use Database\Seeders\InspirationSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InspirationPageTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(InspirationSeeder::class);
    }

    public function test_inspiration_page_shows_redesigned_layout(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('inspiration'));

        $response->assertOk();
        $response->assertSee('Temukan ide dan inspirasi untuk mewujudkan pernikahan impian Anda');
        $response->assertSee('Rekomendasi Untukmu');
        $response->assertSee('Tren Populer');
        $response->assertSee('Mood Favorit');
        $response->assertSee('Koleksi Saya');
        $response->assertSee('Dekorasi Akad Minimalis');
        $response->assertSee('dashboard-shell', false);
    }

    public function test_inspiration_category_filter_limits_results(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('inspiration', ['category' => 'busana']));

        $response->assertOk();
        $response->assertSee('Gaun Pengantin Modern');
        $response->assertDontSee('Dekorasi Akad Minimalis');
    }

    public function test_inspiration_save_toggle_persists_for_user(): void
    {
        $user = User::factory()->create();
        $inspiration = Inspiration::query()->firstOrFail();

        $this->actingAs($user)
            ->post(route('inspiration.save', $inspiration->id))
            ->assertRedirect();

        $this->assertTrue($user->savedInspirations()->whereKey($inspiration->id)->exists());
    }
}
