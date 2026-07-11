<?php

namespace Tests\Feature;

use App\Models\CustomerPreparationTask;
use App\Models\User;
use App\Models\WeddingEvent;
use App\Services\DefaultWeddingChecklistProvisioner;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DefaultWeddingChecklistProvisionerTest extends TestCase
{
    use RefreshDatabase;

    public function test_provisions_checklist_for_default_wedding_events(): void
    {
        $user = User::factory()->create();

        $this->assertSame(4, $user->weddingEvents()->count());
        $this->assertSame(257, CustomerPreparationTask::query()->where('user_id', $user->id)->count());

        $eventIdsByJenis = $user->weddingEvents()->pluck('id', 'jenis_acara');

        $this->assertSame(48, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['lamaran'])->count());
        $this->assertSame(50, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['pengajian'])->count());
        $this->assertSame(77, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['akad'])->count());
        $this->assertSame(82, CustomerPreparationTask::query()->where('wedding_event_id', $eventIdsByJenis['resepsi'])->count());
    }

    public function test_provisioner_is_idempotent_per_event(): void
    {
        $user = User::factory()->create();
        $provisioner = app(DefaultWeddingChecklistProvisioner::class);

        $provisioner->provisionFor($user);

        $this->assertSame(257, CustomerPreparationTask::query()->where('user_id', $user->id)->count());
    }

    public function test_manually_created_event_receives_checklist(): void
    {
        $user = User::factory()->create();
        $user->weddingEvents()->delete();

        $event = WeddingEvent::factory()->create([
            'user_id' => $user->id,
            'jenis_acara' => 'lamaran',
            'sort_order' => 1,
        ]);

        $this->assertSame(48, $event->preparationTasks()->count());
        $this->assertTrue(
            $event->preparationTasks()->whereNotNull('description')->exists()
        );
    }
}
