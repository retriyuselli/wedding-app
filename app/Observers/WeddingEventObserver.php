<?php

namespace App\Observers;

use App\Models\WeddingEvent;
use App\Services\CustomerPreparationTaskDetailEnricher;
use App\Services\DefaultWeddingChecklistProvisioner;

class WeddingEventObserver
{
    public function __construct(
        private DefaultWeddingChecklistProvisioner $checklistProvisioner,
        private CustomerPreparationTaskDetailEnricher $taskDetailEnricher,
    ) {}

    public function created(WeddingEvent $event): void
    {
        $created = $this->checklistProvisioner->provisionForEvent($event);

        if ($created === 0) {
            return;
        }

        $event->loadMissing('user');

        if ($event->user !== null) {
            $this->taskDetailEnricher->enrichFor($event->user);
        }
    }
}
