<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Services\Privacy\TwoFactorAuthService;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class TwoFactorAuthApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
        Mail::fake();
    }

    public function test_user_can_enable_two_factor_with_email_code(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/privacy/two-factor/enable')
            ->assertOk();

        $code = $this->latestPlainCode($user, 'enable');

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/privacy/two-factor/confirm', ['code' => $code])
            ->assertOk()
            ->assertJsonPath('data.enabled', true);

        $this->assertTrue($user->fresh()->two_factor_enabled);
    }

    public function test_login_requires_two_factor_when_enabled(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $user->forceFill([
            'password' => Hash::make('password'),
            'two_factor_enabled' => true,
        ])->save();

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'iPhone Test',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('requires_two_factor', true)
            ->assertJsonStructure(['two_factor_token', 'message']);

        $token = $response->json('two_factor_token');
        $code = $this->latestPlainCode($user, 'login');

        $this->postJson('/api/v1/auth/two-factor/verify', [
            'two_factor_token' => $token,
            'code' => $code,
            'device_name' => 'iPhone Test',
        ])
            ->assertOk()
            ->assertJsonStructure(['user', 'token']);
    }

    public function test_user_can_disable_two_factor(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $user->forceFill([
            'password' => Hash::make('password'),
            'two_factor_enabled' => true,
        ])->save();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/privacy/two-factor/disable')
            ->assertOk();

        $code = $this->latestPlainCode($user, 'disable');

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/privacy/two-factor/confirm-disable', [
                'code' => $code,
                'password' => 'password',
            ])
            ->assertOk()
            ->assertJsonPath('data.enabled', false);

        $this->assertFalse($user->fresh()->two_factor_enabled);
    }

    private function latestPlainCode(User $user, string $purpose): string
    {
        $plain = Cache::get("two_factor:{$purpose}:{$user->id}:plain");

        if (is_string($plain) && $plain !== '') {
            return $plain;
        }

        // Fallback for environments that did not store the plain code.
        $service = app(TwoFactorAuthService::class);
        $reflection = new \ReflectionClass($service);
        $method = $reflection->getMethod('storeAndSendCode');
        $method->setAccessible(true);
        $method->invoke($service, $user, $purpose);

        return (string) Cache::get("two_factor:{$purpose}:{$user->id}:plain");
    }
}
