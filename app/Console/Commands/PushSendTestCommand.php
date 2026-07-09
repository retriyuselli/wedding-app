<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\PushNotificationService;
use Illuminate\Console\Command;

class PushSendTestCommand extends Command
{
    protected $signature = 'push:send-test {email : Email user yang punya device token terdaftar}';

    protected $description = 'Kirim push notification uji ke semua device token user';

    public function handle(PushNotificationService $pushNotificationService): int
    {
        $user = User::query()->where('email', $this->argument('email'))->first();

        if (! $user) {
            $this->components->error('User tidak ditemukan.');

            return self::FAILURE;
        }

        $tokenCount = $user->deviceTokens()->count();

        if ($tokenCount === 0) {
            $this->components->error('User belum punya device token. Buka app iOS, login, dan izinkan notifikasi.');

            return self::FAILURE;
        }

        $sentCount = $pushNotificationService->sendToUser($user, [
            'title' => 'Tes Push Wedding App',
            'body' => 'Notifikasi uji berhasil dikirim dari backend Laravel.',
            'data' => [
                'destination' => 'messages',
                'type' => 'test',
            ],
        ]);

        $driver = (string) config('push.driver');

        if ($driver === 'log') {
            $this->components->warn("PUSH_DRIVER=log — {$tokenCount} token diproses, cek storage/logs/laravel.log.");
        } else {
            $this->components->info("Push terkirim ke {$sentCount} dari {$tokenCount} device token.");
        }

        return self::SUCCESS;
    }
}
