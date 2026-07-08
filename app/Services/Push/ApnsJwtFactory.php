<?php

namespace App\Services\Push;

use Firebase\JWT\JWT;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

class ApnsJwtFactory
{
    public function make(): string
    {
        return Cache::remember('apns.jwt', now()->addMinutes(50), function (): string {
            $keyId = config('push.apns.key_id');
            $teamId = config('push.apns.team_id');
            $privateKey = $this->resolvePrivateKey();

            if (! filled($keyId) || ! filled($teamId) || ! filled($privateKey)) {
                throw new \RuntimeException('Konfigurasi APNs belum lengkap.');
            }

            $payload = [
                'iss' => $teamId,
                'iat' => time(),
            ];

            return JWT::encode($payload, $privateKey, 'ES256', $keyId);
        });
    }

    private function resolvePrivateKey(): ?string
    {
        $configuredKey = config('push.apns.private_key');

        if (! filled($configuredKey)) {
            return null;
        }

        if (Str::startsWith($configuredKey, '-----BEGIN')) {
            return $configuredKey;
        }

        if (! is_file($configuredKey)) {
            throw new \RuntimeException('File private key APNs tidak ditemukan.');
        }

        return file_get_contents($configuredKey) ?: null;
    }
}
