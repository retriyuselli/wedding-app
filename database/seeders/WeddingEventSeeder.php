<?php

namespace Database\Seeders;

use App\Models\User;
use App\Services\DefaultWeddingEventProvisioner;
use Illuminate\Database\Seeder;

class WeddingEventSeeder extends Seeder
{
    public function run(): void
    {
        $provisioner = app(DefaultWeddingEventProvisioner::class);

        User::all()->each(function (User $user) use ($provisioner): void {
            $provisioner->provisionFor($user);
        });
    }
}
