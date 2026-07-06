<?php

namespace Tests\Feature\Api;

use App\Models\CustomerPreparationSubTask;
use App\Models\CustomerPreparationTask;
use App\Models\User;
use Database\Seeders\UserSeeder;
use Database\Seeders\WeddingEventSeeder;
use Database\Seeders\WeddingPreparationChecklistSeeder;
use Database\Seeders\WeddingPreparationTaskDetailsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PreparationSubTaskToggleTest extends TestCase
{
    use RefreshDatabase;

    public function test_sub_task_toggle_cycles_status_and_syncs_parent_task(): void
    {
        $this->seed([
            UserSeeder::class,
            WeddingEventSeeder::class,
            WeddingPreparationChecklistSeeder::class,
            WeddingPreparationTaskDetailsSeeder::class,
        ]);

        $user = User::where('email', 'test@example.com')->firstOrFail();

        $parentTask = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->where('title', 'Menentukan jumlah & jenis hantaran/seserahan')
            ->firstOrFail();

        $subTask = CustomerPreparationSubTask::query()
            ->where('preparation_task_id', $parentTask->id)
            ->where('title', 'Hias & tata seserahan')
            ->firstOrFail();

        $this->assertSame('pending', $subTask->status);
        $this->assertSame('in_progress', $parentTask->fresh()->status);

        $response = $this->actingAs($user, 'sanctum')
            ->patchJson("/api/v1/customer-preparation-sub-tasks/{$subTask->id}/toggle");

        $response
            ->assertOk()
            ->assertJsonPath('data.status', 'in_progress')
            ->assertJsonPath('parent_task_status', 'in_progress');

        $subTask->refresh();
        $this->assertSame('in_progress', $subTask->status);
        $this->assertNull($subTask->completed_at);

        $this->actingAs($user, 'sanctum')
            ->patchJson("/api/v1/customer-preparation-sub-tasks/{$subTask->id}/toggle")
            ->assertOk()
            ->assertJsonPath('data.status', 'done')
            ->assertJsonPath('parent_task_status', 'in_progress');

        $subTask->refresh();
        $this->assertSame('done', $subTask->status);
        $this->assertNotNull($subTask->completed_at);

        $parentTask->refresh();
        $this->assertSame('in_progress', $parentTask->status);

        $this->completeRemainingSubTasks($user, $parentTask);

        $parentTask->refresh();
        $this->assertSame('done', $parentTask->status);
    }

    public function test_user_cannot_toggle_another_users_sub_task(): void
    {
        $this->seed([
            UserSeeder::class,
            WeddingEventSeeder::class,
            WeddingPreparationChecklistSeeder::class,
            WeddingPreparationTaskDetailsSeeder::class,
        ]);

        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $other = User::where('email', 'andi@example.com')->firstOrFail();

        $subTask = CustomerPreparationSubTask::query()
            ->where('user_id', $owner->id)
            ->firstOrFail();

        $this->actingAs($other, 'sanctum')
            ->patchJson("/api/v1/customer-preparation-sub-tasks/{$subTask->id}/toggle")
            ->assertNotFound();
    }

    private function completeRemainingSubTasks(User $user, CustomerPreparationTask $parentTask): void
    {
        CustomerPreparationSubTask::query()
            ->where('preparation_task_id', $parentTask->id)
            ->where('status', '!=', 'done')
            ->get()
            ->each(function (CustomerPreparationSubTask $subTask) use ($user): void {
                while ($subTask->fresh()->status !== 'done') {
                    $this->actingAs($user, 'sanctum')
                        ->patchJson("/api/v1/customer-preparation-sub-tasks/{$subTask->id}/toggle")
                        ->assertOk();
                }
            });
    }
}
