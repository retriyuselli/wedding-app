<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\WeddingBudget;
use App\Models\WeddingBudgetCategoryAllocation;
use App\Models\WeddingIncomingPayment;
use App\Models\WeddingPaymentSchedule;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WeddingBudgetSummaryApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_summary_returns_budget_metrics_for_authenticated_user(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        WeddingBudget::factory()->for($user)->create([
            'total_budget' => 292_000_000,
        ]);

        WeddingPaymentSchedule::factory()->for($user)->create([
            'title' => 'DP Dekorasi',
            'amount' => 109_000_000,
            'status' => 'paid',
            'category' => 'decoration',
        ]);

        WeddingPaymentSchedule::factory()->for($user)->create([
            'title' => 'Sisa Catering',
            'amount' => 25_000_000,
            'status' => 'pending',
            'category' => 'catering',
        ]);

        WeddingBudgetCategoryAllocation::factory()->for($user)->create([
            'category' => 'decoration',
            'allocated_amount' => 80_000_000,
        ]);

        WeddingIncomingPayment::factory()->for($user)->create([
            'amount' => 50_000_000,
            'status' => 'confirmed',
        ]);

        WeddingIncomingPayment::factory()->for($user)->create([
            'amount' => 10_000_000,
            'status' => 'menunggu',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-budget/summary');

        $response
            ->assertOk()
            ->assertJsonPath('data.total_budget', 292000000)
            ->assertJsonPath('data.spent', 109000000)
            ->assertJsonPath('data.commitment', 25000000)
            ->assertJsonPath('data.remaining', 158000000)
            ->assertJsonPath('data.spent_percent', 37)
            ->assertJsonPath('data.planned_allocation_total', 80000000)
            ->assertJsonPath('data.plan_coverage_percent', 27)
            ->assertJsonPath('data.incoming_total', 60000000)
            ->assertJsonPath('data.incoming_confirmed_total', 50000000)
            ->assertJsonPath('data.incoming_pending_count', 1);
    }

    public function test_summary_requires_authentication(): void
    {
        $this->getJson('/api/v1/wedding-budget/summary')
            ->assertUnauthorized();
    }
}
