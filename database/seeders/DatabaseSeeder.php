<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            ShieldRoleSeeder::class,
            WeddingInfoSeeder::class,
            WeddingEventSeeder::class,
            WeddingBudgetSeeder::class,
            WeddingBudgetCategoryAllocationSeeder::class,
            CustomerPaymentMethodSeeder::class,
            WeddingPaymentScheduleSeeder::class,
            WeddingIncomingPaymentSeeder::class,
            WeddingPreparationChecklistSeeder::class,
            WeddingPreparationTaskDetailsSeeder::class,
            FamilyMemberSeeder::class,
            VipGuestSeeder::class,
            GuestSeeder::class,
            CustomerNotificationSeeder::class,
            CategorySeeder::class,
            VendorSeeder::class,
            VendorPackageSeeder::class,
            WeddingQuoteSeeder::class,
            InspirationSeeder::class,
            MessageThreadSeeder::class,
            DocumentFolderSeeder::class,
            WeddingDocumentSeeder::class,
            TrustedDeviceSeeder::class,
        ]);
    }
}
