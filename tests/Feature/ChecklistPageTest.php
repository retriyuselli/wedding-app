<?php

namespace Tests\Feature;

use App\Models\CustomerPreparationTask;
use App\Models\User;
use App\Models\WeddingEvent;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ChecklistPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_checklist_page_shows_redesigned_layout(): void
    {
        $user = User::factory()->create();

        $event = WeddingEvent::factory()->create([
            'user_id' => $user->id,
            'jenis_acara' => 'akad',
            'tgl_acara' => '2026-08-09',
            'lokasi_acara' => 'Aston Palembang',
        ]);

        CustomerPreparationTask::factory()->create([
            'user_id' => $user->id,
            'wedding_event_id' => $event->id,
            'title' => 'Final meeting dengan WO',
            'status' => 'in_progress',
            'due_date' => '2026-07-15',
        ]);

        $response = $this->actingAs($user)->get(route('checklist'));

        $response->assertOk();
        $response->assertSee('Kelola semua tugas persiapan pernikahanmu');
        $response->assertSee('Total Tugas');
        $response->assertSee('Progres Keseluruhan');
        $response->assertSee('Kategori Checklist');
        $response->assertSee('Tugas Mendatang');
        $response->assertSee('Final meeting dengan WO');
        $response->assertSee('dashboard-shell', false);
    }

    public function test_checklist_category_filter_limits_tasks(): void
    {
        $user = User::factory()->create();

        $akadEvent = WeddingEvent::factory()->create([
            'user_id' => $user->id,
            'jenis_acara' => 'akad',
        ]);

        $resepsiEvent = WeddingEvent::factory()->create([
            'user_id' => $user->id,
            'jenis_acara' => 'resepsi',
        ]);

        CustomerPreparationTask::factory()->create([
            'user_id' => $user->id,
            'wedding_event_id' => $akadEvent->id,
            'title' => 'Tugas Akad',
        ]);

        CustomerPreparationTask::factory()->create([
            'user_id' => $user->id,
            'wedding_event_id' => $resepsiEvent->id,
            'title' => 'Tugas Resepsi',
        ]);

        $response = $this->actingAs($user)->get(route('checklist', ['category' => 'akad']));

        $response->assertOk();
        $response->assertSee('Tugas Akad');
        $response->assertDontSee('Tugas Resepsi');
    }
}
