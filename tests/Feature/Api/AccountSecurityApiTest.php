<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AccountSecurityApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_user_can_change_password(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $user->createToken('other-device');
        $currentToken = $user->createToken('current-device');

        $response = $this->withToken($currentToken->plainTextToken)
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'password',
                'password' => 'new-password-123',
                'password_confirmation' => 'new-password-123',
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('message', 'Kata sandi berhasil diubah.');

        $user->refresh();

        $this->assertTrue(Hash::check('new-password-123', $user->password));
        $this->assertDatabaseMissing('personal_access_tokens', [
            'name' => 'other-device',
        ]);
        $this->assertDatabaseHas('personal_access_tokens', [
            'tokenable_id' => $user->id,
            'name' => 'current-device',
        ]);
    }

    public function test_change_password_rejects_invalid_current_password(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'wrong-password',
                'password' => 'new-password-123',
                'password_confirmation' => 'new-password-123',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['current_password']);
    }

    public function test_social_login_user_cannot_change_password(): void
    {
        $user = User::factory()->create([
            'google_id' => 'google-123',
            'password' => Hash::make('password'),
        ]);

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'password',
                'password' => 'new-password-123',
                'password_confirmation' => 'new-password-123',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['current_password']);
    }

    public function test_user_can_delete_account_with_password(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $user->createToken('iphone');

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/auth/account', [
                'password' => 'password',
                'confirmation' => 'HAPUS',
            ])
            ->assertOk()
            ->assertJsonPath('message', 'Akun berhasil dihapus.');

        $this->assertDatabaseMissing('users', [
            'id' => $user->id,
        ]);
        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $user->id,
        ]);
    }

    public function test_delete_account_requires_confirmation_text(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/auth/account', [
                'password' => 'password',
                'confirmation' => 'SALAH',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['confirmation']);
    }

    public function test_social_login_user_can_delete_account_without_password(): void
    {
        $user = User::factory()->create([
            'google_id' => 'google-456',
            'password' => Hash::make('password'),
        ]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/auth/account', [
                'confirmation' => 'HAPUS',
            ])
            ->assertOk()
            ->assertJsonPath('message', 'Akun berhasil dihapus.');

        $this->assertDatabaseMissing('users', [
            'id' => $user->id,
        ]);
    }

    public function test_account_security_endpoints_require_authentication(): void
    {
        $this->putJson('/api/v1/auth/password', [
            'current_password' => 'password',
            'password' => 'new-password-123',
            'password_confirmation' => 'new-password-123',
        ])->assertUnauthorized();

        $this->deleteJson('/api/v1/auth/account', [
            'password' => 'password',
            'confirmation' => 'HAPUS',
        ])->assertUnauthorized();
    }

    public function test_user_can_list_active_sessions(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $currentToken = $user->createToken('iPhone 15');
        $user->createToken('iPad');

        $response = $this->withToken($currentToken->plainTextToken)
            ->getJson('/api/v1/auth/sessions');

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'device_name', 'last_used_at', 'created_at', 'is_current'],
                ],
            ])
            ->assertJsonPath('data.0.device_name', 'iPhone 15')
            ->assertJsonPath('data.0.is_current', true);
    }

    public function test_user_can_revoke_other_session(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $currentToken = $user->createToken('iPhone 15');
        $otherToken = $user->createToken('MacBook');

        $response = $this->withToken($currentToken->plainTextToken)
            ->deleteJson('/api/v1/auth/sessions/'.$otherToken->accessToken->id);

        $response
            ->assertOk()
            ->assertJsonPath('logged_out_current_device', false);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $otherToken->accessToken->id,
        ]);
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $currentToken->accessToken->id,
        ]);
    }

    public function test_user_can_revoke_all_other_sessions(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $currentToken = $user->createToken('iPhone 15');
        $user->createToken('iPad');
        $user->createToken('MacBook');

        $response = $this->withToken($currentToken->plainTextToken)
            ->deleteJson('/api/v1/auth/sessions/others');

        $response
            ->assertOk()
            ->assertJsonPath('revoked_count', 2);

        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $currentToken->accessToken->id,
            'name' => 'iPhone 15',
        ]);
        $this->assertDatabaseMissing('personal_access_tokens', [
            'name' => 'iPad',
        ]);
    }

    public function test_user_cannot_revoke_another_users_session(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $otherUser = User::factory()->create();
        $otherToken = $otherUser->createToken('Android');
        $currentToken = $user->createToken('iPhone 15');

        $this->withToken($currentToken->plainTextToken)
            ->deleteJson('/api/v1/auth/sessions/'.$otherToken->accessToken->id)
            ->assertNotFound();
    }
}
