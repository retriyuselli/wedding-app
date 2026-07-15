<?php

namespace App\Observers;

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
}
