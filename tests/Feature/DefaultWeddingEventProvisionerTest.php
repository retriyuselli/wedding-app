<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\WeddingEvent;
use App\Services\DefaultWeddingEventProvisioner;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DefaultWeddingEventProvisionerTest extends TestCase
{
    use RefreshDatabase;

    public function test_provisions_default_wedding_events_with_staggered_dates(): void
    {
        $user = User::factory()->create([
            'created_at' => '2026-01-15 10:00:00',
        ]);

        $this->assertSame(4, $user->weddingEvents()->count());

        $weddingDay = '2026-04-15';

        $lamaran = $user->weddingEvents()->where('jenis_acara', 'lamaran')->first();
        $this->assertSame('2026-02-14', $lamaran?->tgl_acara?->toDateString());
        $this->assertSame('Rumah', $lamaran?->lokasi_acara);

        $pengajian = $user->weddingEvents()->where('jenis_acara', 'pengajian')->first();
        $this->assertSame('2026-03-16', $pengajian?->tgl_acara?->toDateString());

        $akad = $user->weddingEvents()->where('jenis_acara', 'akad')->first();
        $this->assertSame($weddingDay, $akad?->tgl_acara?->toDateString());
        $this->assertSame('Hotel Aston', $akad?->lokasi_acara);

        $resepsi = $user->weddingEvents()->where('jenis_acara', 'resepsi')->first();
        $this->assertSame($weddingDay, $resepsi?->tgl_acara?->toDateString());
        $this->assertSame('Hotel Aryaduta', $resepsi?->lokasi_acara);
    }

    public function test_provisioner_is_idempotent(): void
    {
        $user = User::factory()->create();
        $provisioner = app(DefaultWeddingEventProvisioner::class);

        $provisioner->provisionFor($user);
        $provisioner->provisionFor($user);

        $this->assertSame(4, $user->weddingEvents()->count());
    }

    public function test_user_observer_provisions_events_on_create(): void
    {
        $user = User::factory()->create([
            'created_at' => '2026-02-01 08:00:00',
        ]);

        $this->assertSame(4, $user->weddingEvents()->count());
        $this->assertSame(
            '2026-05-01',
            $user->weddingEvents()->where('jenis_acara', 'akad')->first()?->tgl_acara?->toDateString()
        );
    }

    public function test_backfill_sets_missing_event_dates(): void
    {
        $user = User::factory()->create([
            'created_at' => '2026-01-01 00:00:00',
        ]);

        $user->weddingEvents()->delete();

        WeddingEvent::factory()->create([
            'user_id' => $user->id,
            'jenis_acara' => 'lamaran',
            'tgl_acara' => null,
            'sort_order' => 1,
        ]);

        WeddingEvent::factory()->create([
            'user_id' => $user->id,
            'jenis_acara' => 'akad',
            'tgl_acara' => null,
            'sort_order' => 3,
        ]);

        $updated = app(DefaultWeddingEventProvisioner::class)->backfillMissingDates($user);

        $this->assertSame(2, $updated);

        $provisioner = app(DefaultWeddingEventProvisioner::class);
        $weddingDay = $provisioner->defaultWeddingDateFor($user->fresh());

        $this->assertSame(
            $provisioner->dateForJenis('lamaran', $weddingDay)->toDateString(),
            $user->weddingEvents()->where('jenis_acara', 'lamaran')->first()?->tgl_acara?->toDateString()
        );
        $this->assertSame(
            $weddingDay->toDateString(),
            $user->weddingEvents()->where('jenis_acara', 'akad')->first()?->tgl_acara?->toDateString()
        );
    }
}
