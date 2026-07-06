<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Database\Seeders\UserSeeder;
use Database\Seeders\WeddingEventSeeder;
use Database\Seeders\WeddingPreparationChecklistSeeder;
use Database\Seeders\WeddingPreparationTaskDetailsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PreparationChecklistApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_receives_seeded_checklist_data(): void
    {
        $this->seed([
            UserSeeder::class,
            WeddingEventSeeder::class,
            WeddingPreparationChecklistSeeder::class,
            WeddingPreparationTaskDetailsSeeder::class,
        ]);

        $user = User::where('email', 'test@example.com')->firstOrFail();

        $eventsResponse = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-events');

        $eventsResponse
            ->assertOk()
            ->assertJsonCount(4, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'jenis_acara', 'jenis_label'],
                ],
            ]);

        $jenisAcara = collect($eventsResponse->json('data'))->pluck('jenis_acara')->sort()->values()->all();
        $this->assertSame(['akad', 'lamaran', 'pengajian', 'resepsi'], $jenisAcara);

        $tasksResponse = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/customer-preparation-tasks');

        $tasksResponse
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'wedding_event_id',
                        'section_id',
                        'title',
                        'description',
                        'notes',
                        'priority',
                        'status',
                        'sort_order',
                        'sub_tasks',
                        'attachments',
                    ],
                ],
            ]);

        $tasks = collect($tasksResponse->json('data'));
        $this->assertSame(257, $tasks->count());

        $this->assertTrue(
            $tasks->every(fn (array $task): bool => filled($task['description']))
        );
        $this->assertTrue(
            $tasks->every(fn (array $task): bool => count($task['sub_tasks']) >= 2)
        );

        $detailTask = $tasks->firstWhere('title', 'Menentukan tanggal dan jam akad');
        $this->assertNotNull($detailTask);
        $this->assertSame('high', $detailTask['priority']);
        $this->assertSame('done', $detailTask['status']);
        $this->assertCount(5, $detailTask['sub_tasks']);
        $this->assertCount(1, $detailTask['attachments']);
        $this->assertStringContainsString('Daftar_Ketersediaan_Penghulu.pdf', $detailTask['attachments'][0]['file_name']);

        $eventIdsByJenis = collect($eventsResponse->json('data'))->pluck('id', 'jenis_acara');

        $this->assertSame(48, $tasks->where('wedding_event_id', $eventIdsByJenis['lamaran'])->count());
        $this->assertSame(50, $tasks->where('wedding_event_id', $eventIdsByJenis['pengajian'])->count());
        $this->assertSame(77, $tasks->where('wedding_event_id', $eventIdsByJenis['akad'])->count());
        $this->assertSame(82, $tasks->where('wedding_event_id', $eventIdsByJenis['resepsi'])->count());

        $this->assertTrue(
            $tasks->contains(fn (array $task): bool => $task['title'] === 'Mendaftarkan pernikahan ke KUA (minimal H-10 hari kerja)')
        );

        $detailedTasks = $tasks->filter(fn (array $task): bool => filled($task['description']));
        $this->assertSame(257, $detailedTasks->count());

        $venueTask = $tasks->firstWhere('title', 'Booking venue & bayar DP');
        $this->assertNotNull($venueTask);
        $this->assertSame('high', $venueTask['priority']);
        $this->assertCount(4, $venueTask['sub_tasks']);
        $this->assertCount(1, $venueTask['attachments']);

        $lamaranTask = $tasks->firstWhere('title', 'Menentukan tanggal & jam acara lamaran');
        $this->assertNotNull($lamaranTask);
        $this->assertNotEmpty($lamaranTask['sub_tasks']);
        $this->assertNotNull($lamaranTask['notes']);

        $totalSubTasks = $tasks->sum(fn (array $task): int => count($task['sub_tasks']));
        $this->assertGreaterThan(700, $totalSubTasks);

        $autoDocumentTask = $tasks->firstWhere('title', 'Fotokopi KTP kedua mempelai');
        $this->assertNotNull($autoDocumentTask);
        $this->assertNotEmpty($autoDocumentTask['attachments']);
    }
}
