<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_user_can_update_profile(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/auth/profile', [
                'name' => 'Budi & Sari',
                'whatsapp' => '081234567890',
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('user.name', 'Budi & Sari')
            ->assertJsonPath('user.whatsapp', '081234567890');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Budi & Sari',
            'whatsapp' => '081234567890',
        ]);
    }

    public function test_profile_update_requires_authentication(): void
    {
        $this->putJson('/api/v1/auth/profile', [
            'name' => 'Guest',
        ])->assertUnauthorized();
    }
}
