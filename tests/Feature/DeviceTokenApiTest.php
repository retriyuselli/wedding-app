<?php

namespace Tests\Feature;

use App\Models\DeviceToken;
use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
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

    public function test_user_can_send_test_push_when_token_exists(): void
    {
        config([
            'push.driver' => 'log',
        ]);

        $user = User::where('email', 'test@example.com')->firstOrFail();
        $this->makeSuperAdmin($user);

        DeviceToken::factory()->for($user)->create([
            'token' => 'apns-test-token',
            'platform' => 'ios',
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/device-tokens/test')
            ->assertOk()
            ->assertJsonPath('data.sent', 1)
            ->assertJsonPath('data.token_count', 1);
    }

    public function test_send_test_push_requires_device_token(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $this->makeSuperAdmin($user);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/device-tokens/test')
            ->assertStatus(422);
    }

    public function test_regular_user_cannot_send_test_or_custom_notification(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/device-tokens/test')
            ->assertForbidden();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/device-tokens/send-notification', [
                'send_to_all' => false,
                'email' => $user->email,
                'title' => 'Tidak boleh',
                'message' => 'Pesan ini harus ditolak.',
            ])
            ->assertForbidden();
    }

    public function test_super_admin_can_send_notification_to_one_user(): void
    {
        config(['push.driver' => 'log']);

        $admin = User::where('email', 'test@example.com')->firstOrFail();
        $this->makeSuperAdmin($admin);

        $recipient = User::factory()->create([
            'email' => 'recipient@example.com',
        ]);
        DeviceToken::factory()->for($recipient)->create([
            'token' => 'recipient-push-token',
            'platform' => 'ios',
        ]);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/device-tokens/send-notification', [
                'send_to_all' => false,
                'email' => $recipient->email,
                'title' => 'Pengumuman',
                'message' => 'Pesan khusus untuk penerima.',
            ])
            ->assertOk()
            ->assertJsonPath('data.recipient_count', 1)
            ->assertJsonPath('data.push_sent', 1);

        $this->assertDatabaseHas('customer_notifications', [
            'user_id' => $recipient->id,
            'title' => 'Pengumuman',
            'message' => 'Pesan khusus untuk penerima.',
        ]);
    }

    private function makeSuperAdmin(User $user): void
    {
        $role = Role::findOrCreate(
            config('filament-shield.super_admin.name', 'super_admin'),
            'web',
        );

        $user->assignRole($role);
    }
}
