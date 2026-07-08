<?php

namespace Database\Factories;

use App\Models\CustomerNotification;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CustomerNotification>
 */
class CustomerNotificationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $templates = [
            [
                'group' => 'payment',
                'title' => 'Pembayaran akan jatuh tempo',
                'message' => 'DP Venue sebesar Rp 5.000.000 jatuh tempo minggu depan.',
                'icon' => 'calendar.badge.clock',
                'destination' => 'budget',
                'tint' => 'warning',
            ],
            [
                'group' => 'guest',
                'title' => 'Tamu mengonfirmasi kehadiran',
                'message' => 'Budi Santoso akan hadir. Meja 12.',
                'icon' => 'person.crop.circle.badge.checkmark',
                'destination' => 'guests',
                'tint' => 'success',
            ],
            [
                'group' => 'preparation',
                'title' => 'Tugas checklist selesai',
                'message' => '"Pesan undangan" pada bagian Undangan sudah ditandai selesai.',
                'icon' => 'checkmark.circle.fill',
                'destination' => 'checklist',
                'tint' => 'success',
            ],
            [
                'group' => 'system',
                'title' => 'Selamat datang di Wedding App',
                'message' => 'Mulai kelola anggaran, checklist, dan daftar tamu pernikahan Anda.',
                'icon' => 'heart.fill',
                'destination' => null,
                'tint' => 'info',
            ],
        ];

        $template = fake()->randomElement($templates);

        return [
            'user_id' => User::factory(),
            'group' => $template['group'],
            'title' => $template['title'],
            'message' => $template['message'],
            'icon' => $template['icon'],
            'destination' => $template['destination'],
            'tint' => $template['tint'],
            'is_unread' => fake()->boolean(40),
        ];
    }
}
