<?php

namespace Tests\Feature\Api;

use App\Models\TrustedDevice;
use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TrustedDeviceApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
    }

    public function test_user_can_register_list_update_and_delete_trusted_device(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $create = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/privacy/trusted-devices', [
                'device_name' => 'iPhone 15 Pro',
                'device_identifier' => 'device-abc-123',
                'platform' => 'ios',
                'is_trusted' => true,
            ]);

        $create
            ->assertCreated()
            ->assertJsonPath('data.device_name', 'iPhone 15 Pro')
            ->assertJsonPath('data.is_trusted', true);

        $deviceId = $create->json('data.id');

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/privacy/trusted-devices?current_device_identifier=device-abc-123')
            ->assertOk()
            ->assertJsonPath('data.0.is_current', true);

        $this->actingAs($user, 'sanctum')
            ->putJson("/api/v1/privacy/trusted-devices/{$deviceId}", [
                'is_trusted' => false,
            ])
            ->assertOk()
            ->assertJsonPath('data.is_trusted', false);

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/privacy/trusted-devices/{$deviceId}")
            ->assertNoContent();

        $this->assertDatabaseMissing('trusted_devices', ['id' => $deviceId]);
    }

    public function test_user_cannot_manage_another_users_device(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $other = User::factory()->create();
        $device = TrustedDevice::factory()->create(['user_id' => $owner->id]);

        $this->actingAs($other, 'sanctum')
            ->deleteJson("/api/v1/privacy/trusted-devices/{$device->id}")
            ->assertNotFound();
    }
}
