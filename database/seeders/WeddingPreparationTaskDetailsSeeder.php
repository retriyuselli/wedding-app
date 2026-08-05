<?php

namespace Database\Seeders;

use App\Models\User;
use App\Services\CustomerPreparationTaskDetailEnricher;
use Illuminate\Database\Seeder;

class WeddingPreparationTaskDetailsSeeder extends Seeder
{
    /**
     * Mengisi detail semua task persiapan:
     * 1. Auto-enrich untuk seluruh task (deskripsi, prioritas, sub tugas, lampiran dokumen).
     * 2. Manual override untuk task-task penting dengan data lebih kaya.
     */
    public function run(): void
    {
        $enricher = app(CustomerPreparationTaskDetailEnricher::class);

        User::all()->each(function (User $user) use ($enricher): void {
            $enricher->enrichFor($user, includeManualOverrides: true);
        });
    }
}
