<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\WeddingEvent;
use Database\Seeders\UserSeeder;
use Database\Seeders\WeddingEventSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WeddingEventApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([
            UserSeeder::class,
            WeddingEventSeeder::class,
        ]);
    }

    public function test_user_can_update_wedding_event_with_ios_payload(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $event = $user->weddingEvents()->where('jenis_acara', 'akad')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/wedding-events/'.$event->id, [
                'jenis_acara' => 'akad',
                'tgl_acara' => '2027-06-23',
                'waktu_mulai' => '10:00',
                'jam_selesai' => '11:00',
                'lokasi_acara' => 'Aryaduta Hotel',
                'estimasi_tamu' => 150,
                'catatan' => 'Mohon konfirmasi ke semua vendor 1 minggu sebelum acara.',
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.lokasi_acara', 'Aryaduta Hotel')
            ->assertJsonPath('data.estimasi_tamu', 150)
            ->assertJsonPath('data.waktu_mulai', '10:00')
            ->assertJsonPath('data.jam_selesai', '11:00');

        $this->assertDatabaseHas('wedding_events', [
            'id' => $event->id,
            'lokasi_acara' => 'Aryaduta Hotel',
            'estimasi_tamu' => 150,
            'waktu_mulai' => '10:00',
            'jam_selesai' => '11:00',
        ]);
    }

    public function test_update_requires_jenis_acara_when_provided_invalid(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $event = $user->weddingEvents()->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/wedding-events/'.$event->id, [
                'jenis_acara' => 'hiburan',
                'tgl_acara' => '2027-06-23',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['jenis_acara']);
    }

    public function test_user_can_partially_update_wedding_event_without_jenis_acara(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $event = $user->weddingEvents()->where('jenis_acara', 'akad')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/wedding-events/'.$event->id, [
                'tgl_acara' => '2027-06-23',
                'lokasi_acara' => 'Aryaduta Hotel',
                'catatan' => 'Catatan baru',
            ])
            ->assertOk()
            ->assertJsonPath('data.lokasi_acara', 'Aryaduta Hotel');

        $event->refresh();

        $this->assertSame('akad', $event->jenis_acara);
        $this->assertSame('Aryaduta Hotel', $event->lokasi_acara);
    }

    public function test_user_can_create_wedding_event_with_time_fields(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $user->weddingEvents()->delete();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-events', [
                'jenis_acara' => 'akad',
                'tgl_acara' => '2027-06-23',
                'waktu_mulai' => '10:00',
                'jam_selesai' => '11:00',
                'lokasi_acara' => 'Lake Maceyhaven, Indonesia',
                'catatan' => 'Catatan acara utama',
            ])
            ->assertCreated()
            ->assertJsonPath('data.jenis_acara', 'akad')
            ->assertJsonPath('data.waktu_mulai', '10:00');

        $this->assertDatabaseHas('wedding_events', [
            'user_id' => $user->id,
            'jenis_acara' => 'akad',
            'lokasi_acara' => 'Lake Maceyhaven, Indonesia',
            'waktu_mulai' => '10:00',
        ]);
    }

    public function test_user_can_add_pengajian_event_quickly_without_queue_worker(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $user->weddingEvents()->where('jenis_acara', 'pengajian')->delete();

        $started = microtime(true);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-events', [
                'jenis_acara' => 'pengajian',
                'sort_order' => 2,
                'tgl_acara' => '2026-09-04',
                'waktu_mulai' => '09:00',
                'jam_selesai' => '11:00',
                'lokasi_acara' => 'Rumah',
            ]);

        $elapsed = microtime(true) - $started;

        $response
            ->assertCreated()
            ->assertJsonPath('data.jenis_acara', 'pengajian')
            ->assertJsonPath('data.waktu_mulai', '09:00');

        $this->assertLessThan(
            8.0,
            $elapsed,
            'Creating an event should stay under iOS timeout without queue/enrich bottlenecks.'
        );

        $event = $user->weddingEvents()->where('jenis_acara', 'pengajian')->first();
        $this->assertNotNull($event);
        $this->assertGreaterThan(0, $event->preparationTasks()->count());
    }

    public function test_store_accepts_time_with_seconds_suffix(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $user->weddingEvents()->delete();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-events', [
                'jenis_acara' => 'lamaran',
                'waktu_mulai' => '14:00:00',
                'jam_selesai' => '16:00:00',
                'lokasi_acara' => 'Rumah',
            ])
            ->assertCreated()
            ->assertJsonPath('data.waktu_mulai', '14:00')
            ->assertJsonPath('data.jam_selesai', '16:00');
    }

    public function test_user_can_update_event_sort_order(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $event = $user->weddingEvents()->where('jenis_acara', 'akad')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/wedding-events/'.$event->id, [
                'sort_order' => 1,
                'lokasi_acara' => 'Rumah Pengantin Perempuan',
            ])
            ->assertOk()
            ->assertJsonPath('data.sort_order', 1)
            ->assertJsonPath('data.lokasi_acara', 'Rumah Pengantin Perempuan');
    }

    public function test_user_can_delete_wedding_event(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $event = $user->weddingEvents()->where('jenis_acara', 'resepsi')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/wedding-events/'.$event->id)
            ->assertNoContent();

        $this->assertDatabaseMissing('wedding_events', [
            'id' => $event->id,
        ]);
    }

    public function test_user_cannot_update_another_users_event(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $otherEvent = WeddingEvent::where('user_id', '!=', $user->id)->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/wedding-events/'.$otherEvent->id, [
                'jenis_acara' => 'akad',
                'tgl_acara' => '2027-06-23',
                'lokasi_acara' => 'Aryaduta Hotel',
            ])
            ->assertNotFound();
    }
}
