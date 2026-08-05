<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class GoogleAuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.google.ios_client_id' => 'test-ios-client.apps.googleusercontent.com',
            'services.google.client_id' => 'test-web-client.apps.googleusercontent.com',
        ]);
    }

    public function test_google_login_creates_user_and_returns_token(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'sub' => 'google-user-123',
                'email' => 'google.user@example.com',
                'name' => 'Google User',
                'picture' => 'https://example.com/avatar.jpg',
                'aud' => 'test-ios-client.apps.googleusercontent.com',
                'email_verified' => 'true',
            ]),
        ]);

        $response = $this->postJson('/api/v1/auth/google', [
            'id_token' => 'valid-token',
            'device_name' => 'iOS Test',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('user.email', 'google.user@example.com')
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);

        $this->assertDatabaseHas('users', [
            'email' => 'google.user@example.com',
            'google_id' => 'google-user-123',
        ]);
    }

    public function test_google_login_links_existing_user_by_email(): void
    {
        $user = User::factory()->create([
            'email' => 'existing@example.com',
            'google_id' => null,
        ]);

        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'sub' => 'google-linked-456',
                'email' => 'existing@example.com',
                'name' => 'Existing User',
                'aud' => 'test-ios-client.apps.googleusercontent.com',
                'email_verified' => 'true',
            ]),
        ]);

        $response = $this->postJson('/api/v1/auth/google', [
            'id_token' => 'valid-token',
            'device_name' => 'iOS Test',
        ]);

        $response->assertOk()->assertJsonPath('user.id', $user->id);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'google_id' => 'google-linked-456',
        ]);
    }

    public function test_google_login_rejects_invalid_token(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([], 400),
        ]);

        $response = $this->postJson('/api/v1/auth/google', [
            'id_token' => 'invalid-token',
            'device_name' => 'iOS Test',
        ]);

        $response->assertUnprocessable();
    }
}
