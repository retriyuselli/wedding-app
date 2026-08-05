<?php

namespace Database\Seeders;

use App\Models\User;
use App\Services\DefaultWeddingChecklistProvisioner;
use Illuminate\Database\Seeder;

class WeddingPreparationChecklistSeeder extends Seeder
{
    /**
     * Seed daftar persiapan (section + task) per jenis acara pernikahan.
     * Sumber data mengikuti checklist di folder `wedding-event/*.md`.
     */
    public function run(): void
    {
        $provisioner = app(DefaultWeddingChecklistProvisioner::class);

        User::all()->each(function (User $user) use ($provisioner): void {
            $provisioner->provisionFor($user);
        });
    }
}
