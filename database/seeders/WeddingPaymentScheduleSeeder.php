<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Database\Seeder;

class WeddingPaymentScheduleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            $eventIds = $user->weddingEvents()->pluck('id');
            $paymentMethodIds = $user->paymentMethods()->pluck('id');

            WeddingPaymentSchedule::factory()
                ->count(5)
                ->create([
                    'user_id'                    => $user->id,
                    'wedding_event_id'           => fn () => $eventIds->random(),
                    'customer_payment_method_id' => fn () => $paymentMethodIds->random(),
                ]);
        });
    }
}
