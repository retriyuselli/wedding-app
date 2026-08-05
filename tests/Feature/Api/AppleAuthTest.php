<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Services\AppleTokenVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Mockery\MockInterface;
use Tests\TestCase;

class AppleAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_apple_login_creates_user_and_returns_token(): void
    {
        $this->mock(AppleTokenVerifier::class, function (MockInterface $mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->with('valid-token')
                ->andReturn([
                    'sub' => 'apple-user-123',
                    'email' => 'apple.user@example.com',
                    'email_verified' => true,
                ]);
        });

        $response = $this->postJson('/api/v1/auth/apple', [
            'identity_token' => 'valid-token',
            'device_name' => 'iOS Test',
            'full_name' => 'Apple User',
            'email' => 'apple.user@example.com',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('user.email', 'apple.user@example.com')
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);

        $this->assertDatabaseHas('users', [
            'email' => 'apple.user@example.com',
            'apple_id' => 'apple-user-123',
        ]);
    }

    public function test_apple_login_links_existing_user_by_email(): void
    {
        $user = User::factory()->create([
            'email' => 'existing@example.com',
            'apple_id' => null,
        ]);

        $this->mock(AppleTokenVerifier::class, function (MockInterface $mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->with('valid-token')
                ->andReturn([
                    'sub' => 'apple-linked-456',
                    'email' => 'existing@example.com',
                    'email_verified' => true,
                ]);
        });

        $response = $this->postJson('/api/v1/auth/apple', [
            'identity_token' => 'valid-token',
            'device_name' => 'iOS Test',
            'full_name' => 'Existing User',
            'email' => 'existing@example.com',
        ]);

        $response->assertOk()->assertJsonPath('user.id', $user->id);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'apple_id' => 'apple-linked-456',
        ]);
    }

    public function test_apple_login_rejects_invalid_token(): void
    {
        $this->mock(AppleTokenVerifier::class, function (MockInterface $mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->with('invalid-token')
                ->andThrow(ValidationException::withMessages([
                    'identity_token' => ['Token Apple tidak valid.'],
                ]));
        });

        $response = $this->postJson('/api/v1/auth/apple', [
            'identity_token' => 'invalid-token',
            'device_name' => 'iOS Test',
        ]);

        $response->assertUnprocessable();
    }
}
