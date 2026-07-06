<?php

namespace Database\Seeders;

use App\Models\CustomerPaymentMethod;
use App\Models\User;
use Illuminate\Database\Seeder;

class CustomerPaymentMethodSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            CustomerPaymentMethod::factory()
                ->count(2)
                ->sequence(['is_primary' => true], ['is_primary' => false])
                ->create(['user_id' => $user->id]);
        });
    }
}
