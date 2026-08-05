<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserDataExportApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
    }

    public function test_user_can_download_data_export_zip(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->get('/api/v1/privacy/data-export');

        $response
            ->assertOk()
            ->assertHeader('content-disposition');

        $this->assertStringContainsString('zip', strtolower((string) $response->headers->get('content-type')));
    }

    public function test_guest_cannot_download_data_export(): void
    {
        $this->getJson('/api/v1/privacy/data-export')
            ->assertUnauthorized();
    }
}
