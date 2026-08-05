<?php

namespace App\Services;

use App\Models\User;
use App\Models\WeddingEvent;
use Illuminate\Support\Carbon;

class DefaultWeddingEventProvisioner
{
    /**
     * @var list<array{jenis_acara: string, sort_order: int, lokasi_acara: string, waktu_mulai: string, jam_selesai: string}>
     */
    private const DEFAULT_EVENTS = [
        [
            'jenis_acara' => 'lamaran',
            'sort_order' => 1,
            'lokasi_acara' => 'Rumah',
            'waktu_mulai' => '14:00',
            'jam_selesai' => '16:00',
        ],
        [
            'jenis_acara' => 'pengajian',
            'sort_order' => 2,
            'lokasi_acara' => 'Rumah',
            'waktu_mulai' => '09:00',
            'jam_selesai' => '11:00',
        ],
        [
            'jenis_acara' => 'akad',
            'sort_order' => 3,
            'lokasi_acara' => 'Hotel Aston',
            'waktu_mulai' => '10:00',
            'jam_selesai' => '11:00',
        ],
        [
            'jenis_acara' => 'resepsi',
            'sort_order' => 4,
            'lokasi_acara' => 'Hotel Aryaduta',
            'waktu_mulai' => '11:30',
            'jam_selesai' => '15:00',
        ],
    ];

    public function provisionFor(User $user): void
    {
        if ($user->weddingEvents()->exists()) {
            return;
        }

        $weddingDay = $this->defaultWeddingDateFor($user);

        foreach (self::DEFAULT_EVENTS as $event) {
            $user->weddingEvents()->create([
                ...$event,
                'tgl_acara' => $this->dateForJenis($event['jenis_acara'], $weddingDay),
            ]);
        }
    }

    public function backfillMissingDates(?User $user = null): int
    {
        $query = WeddingEvent::query()->whereNull('tgl_acara');

        if ($user !== null) {
            $query->where('user_id', $user->id);
        }

        $updated = 0;

        $query->with('user')->orderBy('id')->chunkById(100, function ($events) use (&$updated): void {
            foreach ($events as $event) {
                if ($event->user === null) {
                    continue;
                }

                $weddingDay = $this->defaultWeddingDateFor($event->user);

                $event->update([
                    'tgl_acara' => $this->dateForJenis($event->jenis_acara, $weddingDay),
                ]);

                $updated++;
            }
        });

        return $updated;
    }

    public function defaultWeddingDateFor(User $user): Carbon
    {
        $base = $user->created_at ?? now();

        return $base->copy()->addMonths(3)->startOfDay();
    }

    public function dateForJenis(string $jenisAcara, Carbon $weddingDay): Carbon
    {
        return match ($jenisAcara) {
            'lamaran' => $weddingDay->copy()->subDays(60),
            'pengajian' => $weddingDay->copy()->subDays(30),
            default => $weddingDay->copy(),
        };
    }

    /**
     * @return list<string>
     */
    public static function defaultJenisAcara(): array
    {
        return array_column(self::DEFAULT_EVENTS, 'jenis_acara');
    }

    public static function defaultLocationFor(string $jenisAcara): ?string
    {
        foreach (self::DEFAULT_EVENTS as $event) {
            if ($event['jenis_acara'] === $jenisAcara) {
                return $event['lokasi_acara'];
            }
        }

        return null;
    }
}
