<?php

namespace App\Services;

use App\Models\CustomerPreparationSection;
use App\Models\CustomerPreparationTask;
use App\Models\User;
use App\Models\WeddingEvent;
use App\Support\WeddingPreparationChecklistData;
use Illuminate\Support\Facades\DB;

class DefaultWeddingChecklistProvisioner
{
    public function provisionFor(User $user): int
    {
        $created = 0;

        foreach (WeddingPreparationChecklistData::all() as $jenisAcara => $sections) {
            $event = $user->weddingEvents()
                ->where('jenis_acara', $jenisAcara)
                ->first();

            if (! $event instanceof WeddingEvent) {
                continue;
            }

            $created += $this->provisionForEvent($event, $sections);
        }

        return $created;
    }

    /**
     * @param  array<int, array{title: string, icon: string, tasks: array<int, string>}>|null  $sections
     */
    public function provisionForEvent(WeddingEvent $event, ?array $sections = null): int
    {
        if ($event->preparationTasks()->exists()) {
            return 0;
        }

        $sections ??= WeddingPreparationChecklistData::forJenis($event->jenis_acara);

        if ($sections === []) {
            return 0;
        }

        $userId = $event->user_id;
        $created = 0;

        DB::transaction(function () use ($event, $sections, $userId, &$created): void {
            $sectionSort = 1;

            foreach ($sections as $section) {
                $preparationSection = CustomerPreparationSection::create([
                    'user_id' => $userId,
                    'title' => $section['title'],
                    'icon' => $section['icon'],
                    'sort_order' => $sectionSort++,
                ]);

                $taskSort = 1;

                foreach ($section['tasks'] as $taskTitle) {
                    CustomerPreparationTask::create([
                        'user_id' => $userId,
                        'wedding_event_id' => $event->id,
                        'section_id' => $preparationSection->id,
                        'title' => $taskTitle,
                        'status' => 'pending',
                        'sort_order' => $taskSort++,
                    ]);

                    $created++;
                }
            }
        });

        return $created;
    }
}
