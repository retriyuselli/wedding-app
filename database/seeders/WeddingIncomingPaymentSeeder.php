<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\WeddingIncomingPayment;
use Illuminate\Database\Seeder;

class WeddingIncomingPaymentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            WeddingIncomingPayment::factory()
                ->count(3)
                ->create(['user_id' => $user->id]);
        });
    }
}
