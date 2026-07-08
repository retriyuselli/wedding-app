<?php

namespace Database\Seeders;

use App\Models\Message;
use App\Models\MessageThread;
use App\Models\User;
use Illuminate\Database\Seeder;

class MessageThreadSeeder extends Seeder
{
    public function run(): void
    {
        MessageThread::query()->delete();

        User::query()->each(function (User $user): void {
            $threads = [
                [
                    'name' => 'Grand Ballroom',
                    'category' => 'vendor',
                    'is_online' => true,
                    'messages' => [
                        ['body' => 'Halo, apakah venue tersedia untuk tanggal 12 Agustus?', 'is_outgoing' => true],
                        ['body' => 'Selamat pagi! Venue masih tersedia untuk tanggal tersebut.', 'is_outgoing' => false],
                        ['body' => 'Baik, kami konfirmasi jadwal survey venue besok pukul 14.00.', 'is_outgoing' => false, 'unread' => true],
                    ],
                ],
                [
                    'name' => 'Panitia Akad',
                    'category' => 'committee',
                    'is_online' => true,
                    'messages' => [
                        ['body' => 'Bagaimana progres persiapan akad minggu ini?', 'is_outgoing' => true],
                        ['body' => 'Checklist akad sudah 80% selesai. Mohon review bagian dekorasi.', 'is_outgoing' => false, 'unread' => true],
                    ],
                ],
                [
                    'name' => 'Support Wedding App',
                    'category' => 'support',
                    'is_online' => true,
                    'messages' => [
                        ['body' => 'Halo, saya butuh bantuan mengatur checklist resepsi.', 'is_outgoing' => true],
                        ['body' => 'Ada yang bisa kami bantu terkait perencanaan pernikahan Anda?', 'is_outgoing' => false],
                    ],
                ],
            ];

            foreach ($threads as $threadData) {
                $thread = MessageThread::create([
                    'user_id' => $user->id,
                    'name' => $threadData['name'],
                    'category' => $threadData['category'],
                    'is_online' => $threadData['is_online'],
                ]);

                foreach ($threadData['messages'] as $messageData) {
                    Message::create([
                        'message_thread_id' => $thread->id,
                        'user_id' => $user->id,
                        'body' => $messageData['body'],
                        'is_outgoing' => $messageData['is_outgoing'],
                        'read_at' => ($messageData['is_outgoing'] || empty($messageData['unread'])) ? now() : null,
                        'created_at' => now()->subMinutes(fake()->numberBetween(5, 240)),
                        'updated_at' => now()->subMinutes(fake()->numberBetween(5, 240)),
                    ]);
                }

                $thread->touch();
            }
        });
    }
}
