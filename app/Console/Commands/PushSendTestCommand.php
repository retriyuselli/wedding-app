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
        $email = (string) $this->argument('email');

        $user = User::query()->where('email', $email)->first();

        if (! $user) {
            $this->components->error('User tidak ditemukan.');

            $knownEmails = User::query()
                ->orderBy('email')
                ->limit(5)
                ->pluck('email');

            if ($knownEmails->isNotEmpty()) {
                $this->line('Email terdaftar (contoh):');
                foreach ($knownEmails as $knownEmail) {
                    $this->line("  - {$knownEmail}");
                }
            }

            return self::FAILURE;
        }

        $tokenCount = $user->deviceTokens()->count();

        if ($tokenCount === 0) {
            $this->components->error('User belum punya device token.');
            $this->newLine();
            $this->line('Langkah perbaikan:');
            $this->line('  1. Build ulang app di Xcode (⌘R) ke iPhone fisik — bukan Simulator');
            $this->line('  2. Login → Allow notifikasi');
            $this->line('  3. Cek log Xcode: "[Push] Device token synced to backend"');
            $this->line('  4. Pastikan backend jalan: php artisan serve --host=0.0.0.0 --port=8000');

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
