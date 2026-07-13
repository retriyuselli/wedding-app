<?php

namespace Tests\Feature\Api;

use App\Models\FamilyMember;
use App\Models\Guest;
use App\Models\User;
use App\Models\VipGuest;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GuestBulkDeleteApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
    }

    public function test_destroy_all_guests_for_authenticated_user_only(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $other = User::factory()->create();

        Guest::factory()->count(3)->create(['user_id' => $user->id]);
        Guest::factory()->create(['user_id' => $other->id, 'name' => 'Other Guest']);

        $response = $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/guests-all');

        $response
            ->assertOk()
            ->assertJsonPath('data.deleted', 3);

        $this->assertSame(0, Guest::query()->where('user_id', $user->id)->count());
        $this->assertSame(1, Guest::query()->where('user_id', $other->id)->count());
    }

    public function test_destroy_all_vip_guests(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        VipGuest::factory()->count(2)->create(['user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/vip-guests-all')
            ->assertOk()
            ->assertJsonPath('data.deleted', 2);

        $this->assertSame(0, VipGuest::query()->where('user_id', $user->id)->count());
    }

    public function test_destroy_all_family_members(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        FamilyMember::factory()->count(2)->create(['user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/family-members-all')
            ->assertOk()
            ->assertJsonPath('data.deleted', 2);

        $this->assertSame(0, FamilyMember::query()->where('user_id', $user->id)->count());
    }
}
