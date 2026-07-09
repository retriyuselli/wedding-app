<?php

namespace App\Console\Commands;

use App\Services\Push\ApnsJwtFactory;
use Illuminate\Console\Command;
use Illuminate\Support\Str;
use Throwable;

class PushApnsStatusCommand extends Command
{
    protected $signature = 'push:apns-status';

    protected $description = 'Cek kesiapan konfigurasi push notification APNs';

    public function handle(ApnsJwtFactory $jwtFactory): int
    {
        $driver = (string) config('push.driver');
        $bundleId = (string) config('push.apns.bundle_id');
        $teamId = (string) config('push.apns.team_id');
        $keyId = (string) config('push.apns.key_id');
        $production = (bool) config('push.apns.production');
        $privateKey = (string) config('push.apns.private_key');

        $this->components->twoColumnDetail('Driver', $driver);
        $this->components->twoColumnDetail('Bundle ID', $bundleId ?: '—');
        $this->components->twoColumnDetail('Team ID', $teamId ?: '—');
        $this->components->twoColumnDetail('Key ID', $keyId ?: '—');
        $this->components->twoColumnDetail('Environment', $production ? 'production' : 'sandbox');

        if ($driver === 'log') {
            $this->components->warn('PUSH_DRIVER=log — notifikasi hanya ditulis ke log, tidak dikirim ke perangkat.');

            return self::SUCCESS;
        }

        if ($driver !== 'apns') {
            $this->components->error('PUSH_DRIVER tidak dikenal. Gunakan `log` atau `apns`.');

            return self::FAILURE;
        }

        $issues = $this->collectConfigurationIssues($bundleId, $teamId, $keyId, $privateKey);

        if ($issues !== []) {
            foreach ($issues as $issue) {
                $this->components->error($issue);
            }

            $this->newLine();
            $this->line('Letakkan file .p8 di storage/app/apns/ lalu set APNS_PRIVATE_KEY di .env.');
            $this->line('Contoh: APNS_PRIVATE_KEY=storage/app/apns/AuthKey_XXXXXX.p8');

            return self::FAILURE;
        }

        try {
            $jwtFactory->make();
        } catch (Throwable $exception) {
            $this->components->error('Gagal membuat JWT APNs: '.$exception->getMessage());

            return self::FAILURE;
        }

        $this->components->info('Konfigurasi APNs siap mengirim push notification.');

        return self::SUCCESS;
    }

    /**
     * @return list<string>
     */
    private function collectConfigurationIssues(
        string $bundleId,
        string $teamId,
        string $keyId,
        string $privateKey,
    ): array {
        $issues = [];

        if (! filled($bundleId)) {
            $issues[] = 'APNS_BUNDLE_ID belum diisi.';
        }

        if (! filled($teamId)) {
            $issues[] = 'APNS_TEAM_ID belum diisi.';
        }

        if (! filled($keyId)) {
            $issues[] = 'APNS_KEY_ID belum diisi.';
        }

        if (! filled($privateKey)) {
            $issues[] = 'APNS_PRIVATE_KEY belum diisi.';

            return $issues;
        }

        if (Str::startsWith($privateKey, '-----BEGIN')) {
            return $issues;
        }

        if (! is_file(base_path($privateKey))) {
            $issues[] = "File private key tidak ditemukan: {$privateKey}";
        }

        return $issues;
    }
}
