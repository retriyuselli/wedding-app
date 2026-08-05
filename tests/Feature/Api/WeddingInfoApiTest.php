<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\WeddingInfo;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
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

    public function test_non_premium_user_can_delete_couple_photo(): void
    {
        Storage::fake('public');

        $user = User::factory()->create([
            'is_premium' => false,
        ]);

        $path = 'couple-photos/'.$user->id.'/photo.jpg';
        Storage::disk('public')->put($path, 'fake-image');

        WeddingInfo::factory()->create([
            'user_id' => $user->id,
            'couple_photo' => $path,
        ]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/wedding-info/photo')
            ->assertOk()
            ->assertJsonPath('data.couple_photo_url', null);

        $this->assertDatabaseHas('wedding_infos', [
            'user_id' => $user->id,
            'couple_photo' => null,
        ]);
        Storage::disk('public')->assertMissing($path);
    }

    public function test_authenticated_user_can_download_couple_photo(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $path = 'couple-photos/'.$user->id.'/photo.jpg';
        Storage::disk('public')->put($path, 'fake-image-bytes');

        WeddingInfo::factory()->create([
            'user_id' => $user->id,
            'couple_photo' => $path,
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->get('/api/v1/wedding-info/photo')
            ->assertOk();

        $this->assertSame('fake-image-bytes', $response->streamedContent());
    }

    public function test_couple_photo_url_points_to_authenticated_endpoint(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $path = 'couple-photos/'.$user->id.'/photo.jpg';
        Storage::disk('public')->put($path, 'fake-image-bytes');

        WeddingInfo::factory()->create([
            'user_id' => $user->id,
            'couple_photo' => $path,
        ]);

        $url = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-info')
            ->assertOk()
            ->json('data.couple_photo_url');

        $this->assertIsString($url);
        $this->assertStringContainsString('/api/v1/wedding-info/photo', $url);
    }

    public function test_user_can_upload_couple_photo_via_wedding_info_multipart(): void
    {
        Storage::fake('public');

        $user = User::factory()->create([
            'is_premium' => false,
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->post('/api/v1/wedding-info', [
                'bride_name' => 'Retri',
                'groom_name' => 'Rama',
                'budaya' => 'Adat Jawa',
                'couple_photo' => UploadedFile::fake()->image('couple.jpg', 400, 500),
            ]);

        $response
            ->assertSuccessful()
            ->assertJsonPath('data.bride_name', 'Retri')
            ->assertJsonPath('data.groom_name', 'Rama');

        $url = $response->json('data.couple_photo_url');
        $this->assertIsString($url);
        $this->assertStringContainsString('/api/v1/wedding-info/photo', $url);

        $info = WeddingInfo::query()->where('user_id', $user->id)->first();
        $this->assertNotNull($info?->couple_photo);
        Storage::disk('public')->assertExists($info->couple_photo);
    }

    public function test_non_premium_user_cannot_upload_couple_photo_endpoint(): void
    {
        Storage::fake('public');

        $user = User::factory()->create([
            'is_premium' => false,
        ]);

        $this->actingAs($user, 'sanctum')
            ->post('/api/v1/wedding-info/photo', [
                'couple_photo' => UploadedFile::fake()->image('couple.jpg', 200, 200),
            ])
            ->assertForbidden()
            ->assertJsonPath('code', 'premium_required');
    }
}
