<?php

namespace Tests\Feature\Api;

use App\Models\CustomerPreparationSubTask;
use App\Models\CustomerPreparationTask;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ChecklistFreeCompletionQuotaTest extends TestCase
{
    use RefreshDatabase;

    public function test_non_premium_user_can_read_checklist(): void
    {
        $user = User::factory()->create();
        CustomerPreparationTask::factory()->for($user)->create([
            'title' => 'Cek venue',
            'status' => 'pending',
        ]);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/customer-preparation-tasks')
            ->assertOk()
            ->assertJsonPath('data.0.title', 'Cek venue');
    }

    public function test_non_premium_user_can_complete_twenty_tasks_and_the_next_is_rejected(): void
    {
        $user = User::factory()->create(['is_premium' => false]);
        $tasks = CustomerPreparationTask::factory()->count(21)->for($user)->create([
            'status' => 'pending',
        ]);

        foreach ($tasks->take(20) as $task) {
            $this->actingAs($user, 'sanctum')
                ->putJson("/api/v1/customer-preparation-tasks/{$task->id}", ['status' => 'done'])
                ->assertOk()
                ->assertJsonPath('data.status', 'done');
        }

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/customer-preparation-tasks/'.$tasks->last()->id, ['status' => 'done'])
            ->assertForbidden()
            ->assertJsonPath('code', 'checklist_free_limit');

        $this->assertSame('pending', $tasks->last()->fresh()->status);
    }

    public function test_premium_user_can_complete_more_than_twenty_tasks(): void
    {
        $user = User::factory()->create([
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'premium_activated_at' => now(),
        ]);
        $tasks = CustomerPreparationTask::factory()->count(21)->for($user)->create([
            'status' => 'pending',
        ]);

        CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->whereKeyNot($tasks->last()->id)
            ->update(['status' => 'done']);

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/customer-preparation-tasks/'.$tasks->last()->id, ['status' => 'done'])
            ->assertOk()
            ->assertJsonPath('data.status', 'done');
    }

    public function test_sub_task_cannot_complete_a_twenty_first_parent_task(): void
    {
        $user = User::factory()->create(['is_premium' => false]);
        $done = CustomerPreparationTask::factory()->count(20)->for($user)->create([
            'status' => 'done',
        ]);
        $parent = CustomerPreparationTask::factory()->for($user)->create([
            'status' => 'in_progress',
        ]);
        $subTask = CustomerPreparationSubTask::query()->create([
            'user_id' => $user->id,
            'preparation_task_id' => $parent->id,
            'title' => 'Langkah terakhir',
            'status' => 'in_progress',
            'sort_order' => 1,
        ]);

        $this->actingAs($user, 'sanctum')
            ->patchJson("/api/v1/customer-preparation-sub-tasks/{$subTask->id}/toggle")
            ->assertForbidden()
            ->assertJsonPath('code', 'checklist_free_limit');

        $this->assertSame('in_progress', $subTask->fresh()->status);
        $this->assertSame('in_progress', $parent->fresh()->status);
        $this->assertCount(20, $done);
    }
}
