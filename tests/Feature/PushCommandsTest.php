<?php

namespace Tests\Feature;

use App\Models\DeviceToken;
use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PushCommandsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_push_apns_status_reports_log_driver(): void
    {
        config([
            'push.driver' => 'log',
        ]);

        $this->artisan('push:apns-status')
            ->assertSuccessful();
    }

    public function test_push_apns_status_fails_when_apns_configuration_is_incomplete(): void
    {
        config([
            'push.driver' => 'apns',
            'push.apns.key_id' => null,
            'push.apns.team_id' => null,
            'push.apns.private_key' => null,
        ]);

        $this->artisan('push:apns-status')
            ->assertFailed();
    }

    public function test_push_send_test_requires_registered_device_token(): void
    {
        $this->artisan('push:send-test', ['email' => 'missing@example.com'])
            ->assertFailed();

        $this->artisan('push:send-test', ['email' => 'test@example.com'])
            ->assertFailed();
    }

    public function test_push_send_test_sends_using_log_driver(): void
    {
        config([
            'push.driver' => 'log',
        ]);

        $user = User::where('email', 'test@example.com')->firstOrFail();

        DeviceToken::factory()->for($user)->create([
            'token' => 'test-device-token',
            'platform' => 'ios',
        ]);

        $this->artisan('push:send-test', ['email' => 'test@example.com'])
            ->assertSuccessful();
    }
}
