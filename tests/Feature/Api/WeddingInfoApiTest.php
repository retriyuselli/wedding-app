<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WeddingInfoApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_wedding_info_show_returns_empty_defaults_when_missing(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-info');

        $response
            ->assertOk()
            ->assertJsonPath('data.id', null)
            ->assertJsonPath('data.groom_name', null)
            ->assertJsonPath('data.bride_name', null)
            ->assertJsonPath('data.budaya', null)
            ->assertJsonPath('data.songlist', []);

        $this->assertDatabaseMissing('wedding_infos', [
            'user_id' => $user->id,
        ]);
    }

    public function test_user_can_update_wedding_info(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/wedding-info', [
                'groom_name' => 'Budi Santoso',
                'bride_name' => 'Sari Wulandari',
                'budaya' => 'Adat Jawa',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.groom_name', 'Budi Santoso')
            ->assertJsonPath('data.bride_name', 'Sari Wulandari')
            ->assertJsonPath('data.budaya', 'Adat Jawa');

        $this->assertDatabaseHas('wedding_infos', [
            'user_id' => $user->id,
            'groom_name' => 'Budi Santoso',
            'bride_name' => 'Sari Wulandari',
            'budaya' => 'Adat Jawa',
        ]);
    }
}
