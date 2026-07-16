<?php

namespace Tests\Feature\Api;

use App\Models\Guest;
use App\Models\User;
use App\Models\WeddingBudget;
use App\Models\WeddingInfo;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class PrivacyVisibilityEnforcementApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
    }

    public function test_owner_can_always_view_own_shared_resources(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $owner->update([
            'privacy_settings' => [
                'profile_visibility' => 'private',
                'wedding_visibility' => 'private',
                'guest_list_visibility' => 'private',
                'budget_visibility' => 'private',
                'show_in_directory' => false,
                'allow_vendor_contact' => false,
            ],
        ]);

        WeddingInfo::query()->create([
            'user_id' => $owner->id,
            'bride_name' => 'Ayu',
            'groom_name' => 'Budi',
        ]);
        Guest::query()->create([
            'user_id' => $owner->id,
            'name' => 'Tamu Satu',
            'rsvp_status' => 'menunggu',
        ]);
        WeddingBudget::query()->create([
            'user_id' => $owner->id,
            'total_budget' => 100_000_000,
        ]);

        $this->actingAs($owner, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/profile")
            ->assertOk()
            ->assertJsonPath('meta.viewer_role', 'self');

        $this->actingAs($owner, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/wedding")
            ->assertOk();

        $this->actingAs($owner, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/guests")
            ->assertOk()
            ->assertJsonCount(1, 'data');

        $this->actingAs($owner, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/budget")
            ->assertOk()
            ->assertJsonPath('data.budget.total_budget', 100000000);
    }

    public function test_stranger_is_blocked_when_visibility_is_private(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $stranger = User::where('email', 'andi@example.com')->firstOrFail();

        $owner->update([
            'privacy_settings' => [
                'profile_visibility' => 'private',
                'wedding_visibility' => 'private',
                'guest_list_visibility' => 'private',
                'budget_visibility' => 'private',
            ],
        ]);

        $this->actingAs($stranger, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/profile")
            ->assertForbidden();

        $this->actingAs($stranger, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/wedding")
            ->assertForbidden();

        $this->actingAs($stranger, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/guests")
            ->assertForbidden();

        $this->actingAs($stranger, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/budget")
            ->assertForbidden();
    }

    public function test_linked_partner_can_view_couple_scoped_resources(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $partner = User::where('email', 'siti@example.com')->firstOrFail();

        $owner->update([
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'premium_activated_at' => now(),
            'privacy_settings' => [
                'profile_visibility' => 'couple',
                'wedding_visibility' => 'couple',
                'guest_list_visibility' => 'couple',
                'budget_visibility' => 'couple',
                'partner_user_id' => $partner->id,
            ],
        ]);

        Guest::query()->create([
            'user_id' => $owner->id,
            'name' => 'Tamu Couple',
            'rsvp_status' => 'hadir',
        ]);

        $this->actingAs($partner, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/profile")
            ->assertOk()
            ->assertJsonPath('meta.viewer_role', 'couple');

        $this->actingAs($partner, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/guests")
            ->assertOk()
            ->assertJsonCount(1, 'data');

        $stranger = User::where('email', 'andi@example.com')->firstOrFail();
        $this->actingAs($stranger, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/guests")
            ->assertForbidden();
    }

    public function test_directory_only_lists_public_opt_in_profiles(): void
    {
        $publicUser = User::where('email', 'test@example.com')->firstOrFail();
        $hiddenUser = User::where('email', 'andi@example.com')->firstOrFail();
        $viewer = User::where('email', 'siti@example.com')->firstOrFail();

        $publicUser->update([
            'privacy_settings' => [
                'profile_visibility' => 'public',
                'show_in_directory' => true,
            ],
        ]);
        $hiddenUser->update([
            'privacy_settings' => [
                'profile_visibility' => 'public',
                'show_in_directory' => false,
            ],
        ]);

        $response = $this->actingAs($viewer, 'sanctum')
            ->getJson('/api/v1/shared/directory')
            ->assertOk();

        $ids = collect($response->json('data'))->pluck('id')->all();

        $this->assertContains($publicUser->id, $ids);
        $this->assertNotContains($hiddenUser->id, $ids);
    }

    public function test_authenticated_user_can_view_public_profile(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $viewer = User::where('email', 'andi@example.com')->firstOrFail();

        $owner->update([
            'privacy_settings' => [
                'profile_visibility' => 'public',
            ],
        ]);

        $this->actingAs($viewer, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/profile")
            ->assertOk()
            ->assertJsonPath('meta.viewer_role', 'authenticated');
    }

    public function test_vendor_can_view_wedding_when_visibility_is_vendors(): void
    {
        Role::findOrCreate('vendor');

        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $vendorUser = User::where('email', 'andi@example.com')->firstOrFail();
        $vendorUser->assignRole('vendor');

        $owner->update([
            'privacy_settings' => [
                'wedding_visibility' => 'vendors',
                'allow_vendor_contact' => true,
            ],
        ]);

        $this->actingAs($vendorUser, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/wedding")
            ->assertOk()
            ->assertJsonPath('meta.viewer_role', 'vendor');

        $this->actingAs($vendorUser, 'sanctum')
            ->postJson("/api/v1/shared/users/{$owner->id}/vendor-contact")
            ->assertOk()
            ->assertJsonPath('data.allow_vendor_contact', true);
    }

    public function test_vendor_contact_is_blocked_when_disabled(): void
    {
        Role::findOrCreate('vendor');

        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $vendorUser = User::where('email', 'andi@example.com')->firstOrFail();
        $vendorUser->assignRole('vendor');

        $owner->update([
            'privacy_settings' => [
                'allow_vendor_contact' => false,
            ],
        ]);

        $this->actingAs($vendorUser, 'sanctum')
            ->postJson("/api/v1/shared/users/{$owner->id}/vendor-contact")
            ->assertForbidden();
    }

    public function test_partner_can_be_linked_by_email(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $partner = User::where('email', 'siti@example.com')->firstOrFail();

        $this->actingAs($owner, 'sanctum')
            ->putJson('/api/v1/privacy/visibility', [
                'partner_email' => $partner->email,
                'guest_list_visibility' => 'couple',
            ])
            ->assertOk()
            ->assertJsonPath('data.partner_user_id', $partner->id)
            ->assertJsonPath('data.partner_email', $partner->email)
            ->assertJsonPath('data.partner_name', $partner->name);
    }

    public function test_partner_email_not_found_returns_validation_error(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($owner, 'sanctum')
            ->putJson('/api/v1/privacy/visibility', [
                'partner_email' => 'tidak-ada@example.com',
            ])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['partner_email']);
    }

    public function test_premium_partner_email_can_be_linked(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $partner = User::where('email', 'siti@example.com')->firstOrFail();
        $partner->update([
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'premium_activated_at' => now(),
        ]);

        $this->actingAs($owner, 'sanctum')
            ->putJson('/api/v1/privacy/visibility', [
                'partner_email' => $partner->email,
            ])
            ->assertOk()
            ->assertJsonPath('data.partner_user_id', $partner->id);
    }

    public function test_partner_cannot_view_guests_when_owner_is_not_premium(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $partner = User::where('email', 'siti@example.com')->firstOrFail();

        $owner->update([
            'is_premium' => false,
            'privacy_settings' => [
                'guest_list_visibility' => 'couple',
                'partner_user_id' => $partner->id,
            ],
        ]);

        Guest::query()->create([
            'user_id' => $owner->id,
            'name' => 'Tamu Free Owner',
            'rsvp_status' => 'menunggu',
        ]);

        $this->actingAs($partner, 'sanctum')
            ->getJson("/api/v1/shared/users/{$owner->id}/guests")
            ->assertForbidden();
    }

    public function test_entitlement_lists_shared_premium_access_for_partner(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $partner = User::where('email', 'siti@example.com')->firstOrFail();

        $owner->update([
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'premium_activated_at' => now(),
            'privacy_settings' => [
                'guest_list_visibility' => 'couple',
                'budget_visibility' => 'private',
                'partner_user_id' => $partner->id,
            ],
        ]);

        $this->actingAs($partner, 'sanctum')
            ->getJson('/api/v1/billing/entitlement')
            ->assertOk()
            ->assertJsonPath('data.is_premium', false)
            ->assertJsonPath('data.shared_premium_access.0.user_id', $owner->id)
            ->assertJsonPath('data.shared_premium_access.0.resources', ['guests']);
    }
}
