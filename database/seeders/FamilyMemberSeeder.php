<?php

namespace Database\Seeders;

use App\Models\FamilyMember;
use App\Models\User;
use Illuminate\Database\Seeder;

class FamilyMemberSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            FamilyMember::factory()
                ->count(5)
                ->sequence(fn ($sequence) => ['no' => $sequence->index + 1])
                ->create(['user_id' => $user->id]);
        });
    }
}
