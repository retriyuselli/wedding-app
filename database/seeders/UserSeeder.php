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

    /**
     * @var list<array{
     *     name: string,
     *     email: string,
     *     password: string,
     *     is_premium: bool,
     *     premium_product_id: string|null,
     *     apple_original_transaction_id: string|null
     * }>
     */
    private const APP_REVIEW_USERS = [
        [
            'name' => 'App Review Free',
            'email' => 'review.free@weddingapp.co.id',
            'password' => 'ReviewFree2026!',
            'is_premium' => false,
            'premium_product_id' => null,
            'apple_original_transaction_id' => null,
        ],
        [
            'name' => 'App Review Pro',
            'email' => 'review.pro@weddingapp.co.id',
            'password' => 'ReviewPro2026!',
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'apple_original_transaction_id' => 'app-review-demo-pro',
        ],
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

        foreach (self::APP_REVIEW_USERS as $user) {
            User::query()->updateOrCreate(
                ['email' => $user['email']],
                [
                    'name' => $user['name'],
                    'password' => Hash::make($user['password']),
                    'email_verified_at' => now(),
                    'is_premium' => $user['is_premium'],
                    'premium_product_id' => $user['premium_product_id'],
                    'premium_activated_at' => $user['is_premium'] ? now() : null,
                    'apple_original_transaction_id' => $user['apple_original_transaction_id'],
                ],
            );
        }
    }
}
