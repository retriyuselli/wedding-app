<?php

namespace Tests\Feature;

use App\Models\DeviceToken;
use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeviceTokenApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_user_can_register_device_token(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/device-tokens', [
                'token' => 'apns-device-token-123',
                'platform' => 'ios',
                'device_name' => 'iPhone Ramadho',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.platform', 'ios')
            ->assertJsonPath('data.device_name', 'iPhone Ramadho');

        $this->assertDatabaseHas('device_tokens', [
            'user_id' => $user->id,
            'token' => 'apns-device-token-123',
            'platform' => 'ios',
        ]);
    }

    public function test_registering_existing_token_reassigns_user(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $otherUser = User::factory()->create();

        DeviceToken::factory()->for($otherUser)->create([
            'token' => 'shared-device-token',
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/device-tokens', [
                'token' => 'shared-device-token',
                'platform' => 'ios',
            ])
            ->assertOk();

        $this->assertDatabaseHas('device_tokens', [
            'token' => 'shared-device-token',
            'user_id' => $user->id,
        ]);
    }

    public function test_user_can_unregister_device_token(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        DeviceToken::factory()->for($user)->create([
            'token' => 'token-to-delete',
        ]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/device-tokens', [
                'token' => 'token-to-delete',
            ])
            ->assertNoContent();

        $this->assertDatabaseMissing('device_tokens', [
            'token' => 'token-to-delete',
        ]);
    }
}
