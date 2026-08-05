<?php

namespace App\Observers;

use App\Models\CustomerPreparationTask;
use App\Models\WeddingEvent;
use App\Services\DefaultWeddingChecklistProvisioner;

class WeddingEventObserver
{
    public function created(WeddingEvent $event): void
    {
        // Keep registration / seeder path lightweight (no enricher).
        // Idempotent: skips if checklist already exists for the event.
        app(DefaultWeddingChecklistProvisioner::class)->provisionForEvent($event);
    }

    public function deleting(WeddingEvent $event): void
    {
        // Prefer deleting checklist rows over nullOnDelete orphans, which leave
        // event cards looking empty after an event is recreated.
        CustomerPreparationTask::query()
            ->where('wedding_event_id', $event->id)
            ->each(function (CustomerPreparationTask $task): void {
                $task->subTasks()->delete();
                $task->attachments()->delete();
                $task->delete();
            });
    }
}
