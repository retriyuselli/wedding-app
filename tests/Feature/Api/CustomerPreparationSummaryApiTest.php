<?php

namespace Tests\Feature\Api;

use App\Models\CustomerPreparationTask;
use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CustomerPreparationSummaryApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_summary_returns_task_counts_for_authenticated_user(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        CustomerPreparationTask::factory()->for($user)->create(['status' => 'done']);
        CustomerPreparationTask::factory()->for($user)->create(['status' => 'done']);
        CustomerPreparationTask::factory()->for($user)->create(['status' => 'in_progress']);
        CustomerPreparationTask::factory()->for($user)->create(['status' => 'pending']);
        CustomerPreparationTask::factory()->for($user)->create(['status' => 'pending']);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/customer-preparation-tasks/summary');

        $response
            ->assertOk()
            ->assertJsonPath('data.total', 5)
            ->assertJsonPath('data.completed', 2)
            ->assertJsonPath('data.in_progress', 1)
            ->assertJsonPath('data.todo', 2)
            ->assertJsonPath('data.progress', 0.4);
    }

    public function test_summary_returns_zero_progress_when_user_has_no_tasks(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/customer-preparation-tasks/summary');

        $response
            ->assertOk()
            ->assertJsonPath('data.total', 0)
            ->assertJsonPath('data.completed', 0)
            ->assertJsonPath('data.in_progress', 0)
            ->assertJsonPath('data.todo', 0)
            ->assertJsonPath('data.progress', 0);
    }

    public function test_summary_requires_authentication(): void
    {
        $this->getJson('/api/v1/customer-preparation-tasks/summary')
            ->assertUnauthorized();
    }
}
