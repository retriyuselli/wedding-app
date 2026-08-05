<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;
use UnexpectedValueException;

class AppleTokenVerifier
{
    private const string APPLE_JWKS_URL = 'https://appleid.apple.com/auth/keys';

    private const string APPLE_ISSUER = 'https://appleid.apple.com';

    /**
     * @return array<string, mixed>
     */
    public function verify(string $identityToken): array
    {
        $segments = explode('.', $identityToken);

        if (count($segments) !== 3) {
            throw ValidationException::withMessages([
                'identity_token' => ['Token Apple tidak valid.'],
            ]);
        }

        [$encodedHeader, $encodedPayload, $encodedSignature] = $segments;

        /** @var array<string, mixed>|null $header */
        $header = json_decode($this->base64UrlDecode($encodedHeader), true);
        /** @var array<string, mixed>|null $payload */
        $payload = json_decode($this->base64UrlDecode($encodedPayload), true);

        if (! is_array($header) || ! is_array($payload)) {
            throw ValidationException::withMessages([
                'identity_token' => ['Token Apple tidak valid.'],
            ]);
        }

        $kid = (string) ($header['kid'] ?? '');
        $algorithm = (string) ($header['alg'] ?? '');

        if ($kid === '' || $algorithm !== 'RS256') {
            throw ValidationException::withMessages([
                'identity_token' => ['Token Apple tidak valid.'],
            ]);
        }

        $publicKey = $this->resolvePublicKey($kid);

        $signedData = $encodedHeader.'.'.$encodedPayload;
        $signature = $this->base64UrlDecode($encodedSignature);

        $verified = openssl_verify($signedData, $signature, $publicKey, OPENSSL_ALGO_SHA256);

        if ($verified !== 1) {
            throw ValidationException::withMessages([
                'identity_token' => ['Token Apple tidak valid.'],
            ]);
        }

        $this->validateClaims($payload);

        return $payload;
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function validateClaims(array $payload): void
    {
        $issuer = (string) ($payload['iss'] ?? '');
        if ($issuer !== self::APPLE_ISSUER) {
            throw ValidationException::withMessages([
                'identity_token' => ['Token Apple tidak valid.'],
            ]);
        }

        $audience = (string) ($payload['aud'] ?? '');
        $allowedAudiences = array_filter([
            config('services.apple.client_id'),
            config('services.apple.ios_client_id'),
        ]);

        if ($allowedAudiences === [] || ! in_array($audience, $allowedAudiences, true)) {
            throw ValidationException::withMessages([
                'identity_token' => ['Token Apple tidak valid untuk aplikasi ini.'],
            ]);
        }

        $expiresAt = (int) ($payload['exp'] ?? 0);
        if ($expiresAt <= time()) {
            throw ValidationException::withMessages([
                'identity_token' => ['Token Apple sudah kedaluwarsa.'],
            ]);
        }

        $subject = (string) ($payload['sub'] ?? '');
        if ($subject === '') {
            throw ValidationException::withMessages([
                'identity_token' => ['Identitas Apple tidak tersedia.'],
            ]);
        }
    }

    private function resolvePublicKey(string $kid): string
    {
        /** @var array<int, array<string, mixed>> $keys */
        $keys = Cache::remember('apple_jwks_keys', now()->addHours(12), function (): array {
            $response = Http::get(self::APPLE_JWKS_URL);

            if (! $response->ok()) {
                throw ValidationException::withMessages([
                    'identity_token' => ['Tidak dapat memverifikasi token Apple.'],
                ]);
            }

            /** @var array<string, mixed> $body */
            $body = $response->json();
            $keys = $body['keys'] ?? [];

            return is_array($keys) ? $keys : [];
        });

        foreach ($keys as $key) {
            if (! is_array($key) || ($key['kid'] ?? null) !== $kid) {
                continue;
            }

            return $this->jwkToPem($key);
        }

        throw ValidationException::withMessages([
            'identity_token' => ['Kunci verifikasi Apple tidak ditemukan.'],
        ]);
    }

    /**
     * @param  array<string, mixed>  $jwk
     */
    private function jwkToPem(array $jwk): string
    {
        $modulus = $this->base64UrlDecode((string) ($jwk['n'] ?? ''));
        $exponent = $this->base64UrlDecode((string) ($jwk['e'] ?? ''));

        if ($modulus === '' || $exponent === '') {
            throw new UnexpectedValueException('Invalid Apple JWK.');
        }

        $modulus = "\x00".$modulus;
        $exponent = "\x00".$exponent;

        $modulus = $this->encodeLengthPrefixed($modulus);
        $exponent = $this->encodeLengthPrefixed($exponent);

        $rsaPublicKey = "\x30".$this->encodeLength(strlen($modulus.$exponent)).$modulus.$exponent;
        $bitString = "\x03".$this->encodeLength(strlen($rsaPublicKey) + 1)."\x00".$rsaPublicKey;

        $rsaOid = hex2bin('300d06092a864886f70d0101010500');
        $publicKeyInfo = "\x30".$this->encodeLength(strlen($rsaOid.$bitString)).$rsaOid.$bitString;
        $pem = "-----BEGIN PUBLIC KEY-----\n"
            .chunk_split(base64_encode($publicKeyInfo), 64, "\n")
            ."-----END PUBLIC KEY-----\n";

        return $pem;
    }

    private function encodeLengthPrefixed(string $value): string
    {
        return "\x02".$this->encodeLength(strlen($value)).$value;
    }

    private function encodeLength(int $length): string
    {
        if ($length < 128) {
            return chr($length);
        }

        $bytes = ltrim(pack('N', $length), "\x00");

        return chr(0x80 | strlen($bytes)).$bytes;
    }

    private function base64UrlDecode(string $value): string
    {
        $remainder = strlen($value) % 4;
        if ($remainder > 0) {
            $value .= str_repeat('=', 4 - $remainder);
        }

        $decoded = base64_decode(strtr($value, '-_', '+/'), true);

        return $decoded === false ? '' : $decoded;
    }
}
