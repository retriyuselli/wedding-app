<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\WeddingBudgetCategoryAllocation;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WeddingBudgetCategoryAllocationApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_index_returns_only_authenticated_user_allocations(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $otherUser = User::where('email', '!=', 'test@example.com')->firstOrFail();

        WeddingBudgetCategoryAllocation::factory()->create([
            'user_id' => $user->id,
            'category' => 'venue',
            'allocated_amount' => 25_000_000,
        ]);

        WeddingBudgetCategoryAllocation::factory()->create([
            'user_id' => $otherUser->id,
            'category' => 'catering',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-budget-category-allocations');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.category', 'venue')
            ->assertJsonPath('data.0.category_label', 'Venue')
            ->assertJsonPath('data.0.allocated_amount', 25000000);
    }

    public function test_store_creates_category_allocation(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-budget-category-allocations', [
                'category' => 'decoration',
                'allocated_amount' => 12_500_000,
                'notes' => 'Dekorasi utama',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.category', 'decoration')
            ->assertJsonPath('data.category_label', 'Dekorasi')
            ->assertJsonPath('data.allocated_amount', 12500000)
            ->assertJsonPath('data.notes', 'Dekorasi utama');

        $this->assertDatabaseHas('wedding_budget_category_allocations', [
            'user_id' => $user->id,
            'category' => 'decoration',
            'allocated_amount' => 12500000,
        ]);
    }

    public function test_store_rejects_duplicate_category_for_same_user(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        WeddingBudgetCategoryAllocation::factory()->create([
            'user_id' => $user->id,
            'category' => 'venue',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-budget-category-allocations', [
                'category' => 'venue',
                'allocated_amount' => 10_000_000,
            ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['category']);
    }

    public function test_update_changes_allocated_amount(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $allocation = WeddingBudgetCategoryAllocation::factory()->create([
            'user_id' => $user->id,
            'category' => 'catering',
            'allocated_amount' => 10_000_000,
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->putJson("/api/v1/wedding-budget-category-allocations/{$allocation->id}", [
                'allocated_amount' => 18_000_000,
                'notes' => 'Revisi catering',
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.allocated_amount', 18000000)
            ->assertJsonPath('data.notes', 'Revisi catering');

        $this->assertDatabaseHas('wedding_budget_category_allocations', [
            'id' => $allocation->id,
            'allocated_amount' => 18000000,
        ]);
    }

    public function test_destroy_deletes_allocation(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $allocation = WeddingBudgetCategoryAllocation::factory()->create([
            'user_id' => $user->id,
            'category' => 'wo',
        ]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/wedding-budget-category-allocations/{$allocation->id}")
            ->assertNoContent();

        $this->assertDatabaseMissing('wedding_budget_category_allocations', [
            'id' => $allocation->id,
        ]);
    }

    public function test_user_cannot_access_other_users_allocation(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $otherUser = User::where('email', '!=', 'test@example.com')->firstOrFail();

        $allocation = WeddingBudgetCategoryAllocation::factory()->create([
            'user_id' => $otherUser->id,
            'category' => 'transport',
        ]);

        $this->actingAs($user, 'sanctum')
            ->getJson("/api/v1/wedding-budget-category-allocations/{$allocation->id}")
            ->assertNotFound();
    }
}
