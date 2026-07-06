<?php

namespace Database\Seeders;

use App\Models\CustomerNotification;
use App\Models\User;
use Illuminate\Database\Seeder;

class CustomerNotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            CustomerNotification::factory()
                ->count(5)
                ->create(['user_id' => $user->id]);
        });
    }
}
