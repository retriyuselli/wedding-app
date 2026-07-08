<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\DefaultWeddingEventProvisioner;
use Illuminate\Console\Command;

class BackfillWeddingEventDatesCommand extends Command
{
    protected $signature = 'wedding-events:backfill-dates {--user= : Backfill for a specific user ID only}';

    protected $description = 'Fill missing tgl_acara on wedding events using default schedule offsets';

    public function handle(DefaultWeddingEventProvisioner $provisioner): int
    {
        $userId = $this->option('user');

        $user = $userId !== null
            ? User::query()->findOrFail($userId)
            : null;

        $updated = $provisioner->backfillMissingDates($user);

        $this->info("Updated {$updated} wedding event date(s).");

        return self::SUCCESS;
    }
}
