<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PrivacySecurityApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
    }

    public function test_user_can_fetch_security_summary(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/privacy/summary')
            ->assertOk()
            ->assertJsonPath('data.status', fn ($status) => in_array($status, ['secure', 'attention'], true))
            ->assertJsonStructure([
                'data' => [
                    'status',
                    'title',
                    'message',
                    'score',
                    'checks' => [
                        ['key', 'passed', 'label', 'detail'],
                    ],
                ],
            ]);
    }

    public function test_user_can_get_and_update_visibility_settings(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/privacy/visibility')
            ->assertOk()
            ->assertJsonPath('data.profile_visibility', 'private');

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/privacy/visibility', [
                'profile_visibility' => 'couple',
                'show_in_directory' => true,
            ])
            ->assertOk()
            ->assertJsonPath('data.profile_visibility', 'couple')
            ->assertJsonPath('data.show_in_directory', true);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
        ]);

        $this->assertSame('couple', $user->fresh()->privacy_settings['profile_visibility']);
    }

    public function test_user_can_fetch_app_permissions_catalog(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/privacy/app-permissions')
            ->assertOk()
            ->assertJsonCount(4, 'data')
            ->assertJsonPath('data.0.key', 'notifications');
    }
}
