<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\WeddingEvent;
use Illuminate\Database\Seeder;

class WeddingEventSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::all()->each(function (User $user): void {
            WeddingEvent::factory()
                ->count(4)
                ->sequence(
                    ['jenis_acara' => 'lamaran'],
                    ['jenis_acara' => 'pengajian'],
                    ['jenis_acara' => 'akad'],
                    ['jenis_acara' => 'resepsi'],
                )
                ->create(['user_id' => $user->id]);
        });
    }
}
