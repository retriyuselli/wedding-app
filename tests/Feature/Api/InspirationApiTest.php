<?php

namespace Tests\Feature\Api;

use App\Models\Inspiration;
use App\Models\User;
use Database\Seeders\InspirationSeeder;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InspirationApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([
            UserSeeder::class,
            InspirationSeeder::class,
        ]);
    }

    public function test_index_returns_active_inspirations(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/inspirations');

        $response
            ->assertOk()
            ->assertJsonCount(10, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'title', 'description', 'category', 'likes', 'views', 'is_saved', 'is_liked'],
                ],
            ]);
    }

    public function test_index_can_filter_by_category_and_saved_only(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $inspiration = Inspiration::query()->where('category', 'dekorasi')->firstOrFail();

        $user->savedInspirations()->attach($inspiration->id);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/inspirations?category=dekorasi&saved_only=1');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $inspiration->id)
            ->assertJsonPath('data.0.is_saved', true);
    }

    public function test_save_and_unsave_inspiration(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $inspiration = Inspiration::query()->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/inspirations/'.$inspiration->id.'/save')
            ->assertOk()
            ->assertJsonPath('data.is_saved', true);

        $this->assertDatabaseHas('inspiration_user', [
            'user_id' => $user->id,
            'inspiration_id' => $inspiration->id,
        ]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/inspirations/'.$inspiration->id.'/save')
            ->assertNoContent();

        $this->assertDatabaseMissing('inspiration_user', [
            'user_id' => $user->id,
            'inspiration_id' => $inspiration->id,
        ]);
    }

    public function test_like_and_unlike_inspiration(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $inspiration = Inspiration::query()->firstOrFail();
        $initialLikes = $inspiration->likes_count;

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/inspirations/'.$inspiration->id.'/like')
            ->assertOk()
            ->assertJsonPath('data.is_liked', true)
            ->assertJsonPath('data.likes', $initialLikes + 1);

        $this->assertDatabaseHas('inspiration_likes', [
            'user_id' => $user->id,
            'inspiration_id' => $inspiration->id,
        ]);

        $this->assertDatabaseHas('inspirations', [
            'id' => $inspiration->id,
            'likes_count' => $initialLikes + 1,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/inspirations/'.$inspiration->id.'/like')
            ->assertOk()
            ->assertJsonPath('data.likes', $initialLikes + 1);

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/inspirations/'.$inspiration->id.'/like')
            ->assertOk()
            ->assertJsonPath('data.is_liked', false)
            ->assertJsonPath('data.likes', $initialLikes);

        $this->assertDatabaseMissing('inspiration_likes', [
            'user_id' => $user->id,
            'inspiration_id' => $inspiration->id,
        ]);
    }

    public function test_index_requires_authentication(): void
    {
        $this->getJson('/api/v1/inspirations')
            ->assertUnauthorized();
    }

    public function test_index_resolves_relative_image_urls_to_public_storage(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $inspiration = Inspiration::query()->firstOrFail();
        $inspiration->update(['image_url' => 'inspirations/sample.jpg']);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/inspirations');

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.0.image_url',
                asset('storage/inspirations/sample.jpg'),
            );
    }
}
