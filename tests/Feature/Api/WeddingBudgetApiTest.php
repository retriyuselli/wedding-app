<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\WeddingBudget;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WeddingBudgetApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_wedding_budget_show_returns_empty_defaults_when_missing(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-budget');

        $response
            ->assertOk()
            ->assertJsonPath('data.id', null)
            ->assertJsonPath('data.total_budget', 0)
            ->assertJsonPath('data.currency', WeddingBudget::defaultCurrency())
            ->assertJsonPath('data.notes', null);

        $this->assertDatabaseMissing('wedding_budgets', [
            'user_id' => $user->id,
        ]);
    }

    public function test_user_can_update_wedding_budget(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/wedding-budget', [
                'total_budget' => 150000000,
                'currency' => 'IDR',
                'notes' => 'Target pernikahan',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.total_budget', 150000000)
            ->assertJsonPath('data.currency', 'IDR')
            ->assertJsonPath('data.notes', 'Target pernikahan');

        $this->assertDatabaseHas('wedding_budgets', [
            'user_id' => $user->id,
            'total_budget' => 150000000,
            'currency' => 'IDR',
            'notes' => 'Target pernikahan',
        ]);
    }
}
