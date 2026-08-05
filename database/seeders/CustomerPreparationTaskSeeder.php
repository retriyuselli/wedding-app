<?php

namespace Database\Seeders;

use App\Models\CustomerPreparationTask;
use App\Models\User;
use Illuminate\Database\Seeder;

/**
 * Orphan / legacy — jangan dipanggil dari DatabaseSeeder.
 * Checklist resmi memakai WeddingPreparationChecklistSeeder
 * + WeddingPreparationTaskDetailsSeeder.
 */
class CustomerPreparationTaskSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            $eventIds = $user->weddingEvents()->pluck('id');
            $sectionIds = $user->preparationSections()->pluck('id');

            CustomerPreparationTask::factory()
                ->count(6)
                ->create([
                    'user_id'          => $user->id,
                    'wedding_event_id' => fn () => $eventIds->random(),
                    'section_id'       => fn () => $sectionIds->random(),
                ]);
        });
    }
}
