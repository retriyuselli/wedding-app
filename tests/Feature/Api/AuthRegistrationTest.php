<?php

namespace Tests\Feature\Api;

use App\Models\CustomerPreparationTask;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthRegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_creates_default_wedding_events(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Pengantin Baru',
            'email' => 'baru@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'device_name' => 'iPhone Test',
        ]);

        $response->assertCreated();

        $user = User::where('email', 'baru@example.com')->firstOrFail();
        $weddingDay = $user->created_at->copy()->addMonths(3)->toDateString();

        $this->assertSame(4, $user->weddingEvents()->count());

        $events = $user->weddingEvents()->get()->keyBy('jenis_acara');

        $this->assertSame('Rumah', $events['lamaran']->lokasi_acara);
        $this->assertNotNull($events['lamaran']->tgl_acara);

        $this->assertSame($weddingDay, $events['akad']->tgl_acara?->toDateString());
        $this->assertSame('Hotel Aston', $events['akad']->lokasi_acara);

        $this->assertSame($weddingDay, $events['resepsi']->tgl_acara?->toDateString());
        $this->assertSame('Hotel Aryaduta', $events['resepsi']->lokasi_acara);
    }

    public function test_register_creates_default_preparation_checklists(): void
    {
        $this->postJson('/api/v1/auth/register', [
            'name' => 'Pengantin Baru',
            'email' => 'checklist@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'device_name' => 'iPhone Test',
        ])->assertCreated();

        $user = User::where('email', 'checklist@example.com')->firstOrFail();
        $eventIdsByJenis = $user->weddingEvents()->pluck('id', 'jenis_acara');

        $this->assertSame(257, CustomerPreparationTask::query()->where('user_id', $user->id)->count());
        $this->assertSame(48, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['lamaran'])->count());
        $this->assertSame(50, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['pengajian'])->count());
        $this->assertSame(77, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['akad'])->count());
        $this->assertSame(82, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['resepsi'])->count());

        $task = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->where('title', 'Menentukan tanggal & jam acara lamaran')
            ->first();

        $this->assertNotNull($task);
        $this->assertNotNull($task->description);
        $this->assertGreaterThanOrEqual(2, $task->subTasks()->count());
    }
}
