<?php

namespace Database\Seeders;

use App\Models\CustomerPreparationSection;
use App\Models\User;
use Illuminate\Database\Seeder;

class CustomerPreparationSectionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            CustomerPreparationSection::factory()
                ->count(3)
                ->sequence(
                    ['title' => 'Dokumen', 'sort_order' => 1],
                    ['title' => 'Vendor', 'sort_order' => 2],
                    ['title' => 'Busana', 'sort_order' => 3],
                )
                ->create(['user_id' => $user->id]);
        });
    }
}
