<?php

namespace Tests\Feature\Api;

use App\Models\CustomerPreparationSubTask;
use App\Models\CustomerPreparationTask;
use App\Models\User;
use App\Models\WeddingEvent;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PreparationTaskCreateApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_task_with_sub_tasks(): void
    {
        $user = User::factory()->create();
        $event = WeddingEvent::factory()->for($user)->create([
            'jenis_acara' => 'resepsi',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/customer-preparation-tasks', [
                'title' => 'Booking fotografer',
                'priority' => 'high',
                'wedding_event_id' => $event->id,
                'description' => 'Cari vendor yang match tema',
                'sub_tasks' => [
                    ['title' => 'Shortlist 3 vendor'],
                    ['title' => 'Jadwalkan meeting'],
                    ['title' => 'Tanda tangan kontrak'],
                ],
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.title', 'Booking fotografer')
            ->assertJsonPath('data.priority', 'high')
            ->assertJsonCount(3, 'data.sub_tasks')
            ->assertJsonPath('data.sub_tasks.0.title', 'Shortlist 3 vendor')
            ->assertJsonPath('data.sub_tasks.2.title', 'Tanda tangan kontrak');

        $taskId = (int) $response->json('data.id');
        $this->assertSame(3, CustomerPreparationSubTask::query()->where('preparation_task_id', $taskId)->count());
    }

    public function test_user_can_create_task_without_sub_tasks(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/customer-preparation-tasks', [
                'title' => 'Pesan undangan',
            ])
            ->assertCreated()
            ->assertJsonCount(0, 'data.sub_tasks');
    }
}
