<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * @var list<array{name: string, email: string}>
     */
    private const USERS = [
        ['name' => 'Test User', 'email' => 'test@example.com'],
        ['name' => 'Andi Pratama', 'email' => 'andi@example.com'],
        ['name' => 'Siti Rahma', 'email' => 'siti@example.com'],
        ['name' => 'Ramadhona Utama', 'email' => 'ramadhona.utama@gmail.com'],
    ];

    public function run(): void
    {
        foreach (self::USERS as $user) {
            User::query()->updateOrCreate(
                ['email' => $user['email']],
                [
                    'name' => $user['name'],
                    'password' => Hash::make('password'),
                    'email_verified_at' => now(),
                ],
            );
        }
    }
}
