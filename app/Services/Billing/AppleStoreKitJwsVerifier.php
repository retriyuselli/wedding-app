<?php

namespace App\Services\Billing;

use InvalidArgumentException;

class AppleStoreKitJwsVerifier
{
    /**
     * Cryptographically verify a StoreKit 2 signed transaction JWS.
     *
     * @return array<string, mixed>
     */
    public function verify(string $signedTransaction): array
    {
        if (config('billing.apple_jws_verification_bypass')) {
            return $this->decodePayloadWithoutCrypto($signedTransaction);
        }

        $parts = explode('.', $signedTransaction);
        if (count($parts) !== 3) {
            throw new InvalidArgumentException('Format transaksi Apple tidak valid.');
        }

        [$encodedHeader, $encodedPayload, $encodedSignature] = $parts;

        /** @var array<string, mixed>|null $header */
        $header = json_decode($this->base64UrlDecode($encodedHeader), true);
        if (! is_array($header)) {
            throw new InvalidArgumentException('Header transaksi Apple tidak valid.');
        }

        if (($header['alg'] ?? '') !== 'ES256') {
            throw new InvalidArgumentException('Algoritma tanda tangan Apple tidak valid.');
        }

        $x5c = $header['x5c'] ?? null;
        if (! is_array($x5c) || $x5c === []) {
            throw new InvalidArgumentException('Sertifikat transaksi Apple tidak ditemukan.');
        }

        $publicKey = $this->validateCertificateChainAndGetPublicKey($x5c);

        $signedData = $encodedHeader.'.'.$encodedPayload;
        $signature = $this->base64UrlDecode($encodedSignature);
        $derSignature = $this->ecdsaRawToDer($signature);

        $verified = openssl_verify($signedData, $derSignature, $publicKey, OPENSSL_ALGO_SHA256);
        if ($verified !== 1) {
            throw new InvalidArgumentException('Tanda tangan transaksi Apple tidak valid.');
        }

        /** @var array<string, mixed>|null $payload */
        $payload = json_decode($this->base64UrlDecode($encodedPayload), true);
        if (! is_array($payload)) {
            throw new InvalidArgumentException('Payload transaksi Apple tidak valid.');
        }

        $this->validatePayload($payload);

        return $payload;
    }

    /**
     * @param  array<int, string>  $x5c
     */
    private function validateCertificateChainAndGetPublicKey(array $x5c): string
    {
        $certificates = [];

        foreach ($x5c as $encoded) {
            if (! is_string($encoded) || strlen($encoded) > 16384) {
                throw new InvalidArgumentException('Sertifikat transaksi Apple tidak valid.');
            }

            $resource = openssl_x509_read($this->certificateToPem($encoded));
            if ($resource === false) {
                throw new InvalidArgumentException('Sertifikat transaksi Apple tidak dapat dibaca.');
            }

            $certificates[] = $resource;
        }

        for ($index = 0; $index < count($certificates) - 1; $index++) {
            if (openssl_x509_verify($certificates[$index], $certificates[$index + 1]) !== 1) {
                throw new InvalidArgumentException('Rantai sertifikat Apple tidak valid.');
            }
        }

        $appleRoot = openssl_x509_read($this->appleRootCaPem());
        if ($appleRoot === false) {
            throw new InvalidArgumentException('Root CA Apple tidak tersedia.');
        }

        $chainRoot = $certificates[array_key_last($certificates)];
        if (openssl_x509_verify($chainRoot, $appleRoot) !== 1
            && ! $this->certificateFingerprintsMatch($chainRoot, $appleRoot)) {
            throw new InvalidArgumentException('Root sertifikat Apple tidak dikenali.');
        }

        $leafKey = openssl_pkey_get_public($certificates[0]);
        if ($leafKey === false) {
            throw new InvalidArgumentException('Kunci publik transaksi Apple tidak valid.');
        }

        $details = openssl_pkey_get_details($leafKey);
        if ($details === false || ! isset($details['key'])) {
            throw new InvalidArgumentException('Kunci publik transaksi Apple tidak valid.');
        }

        return $details['key'];
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function validatePayload(array $payload): void
    {
        $bundleId = (string) config('billing.apple_bundle_id', 'com.weddingapp.ios');
        $payloadBundleId = (string) ($payload['bundleId'] ?? '');

        if ($payloadBundleId !== '' && $payloadBundleId !== $bundleId) {
            throw new InvalidArgumentException('Bundle ID transaksi tidak cocok.');
        }

        if (array_key_exists('revocationDate', $payload) && $payload['revocationDate'] !== null) {
            throw new InvalidArgumentException('Transaksi Apple telah dibatalkan.');
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function decodePayloadWithoutCrypto(string $signedTransaction): array
    {
        $parts = explode('.', $signedTransaction);
        if (count($parts) !== 3) {
            throw new InvalidArgumentException('Format transaksi Apple tidak valid.');
        }

        /** @var array<string, mixed>|null $payload */
        $payload = json_decode($this->base64UrlDecode($parts[1]), true);
        if (! is_array($payload)) {
            throw new InvalidArgumentException('Payload transaksi Apple tidak valid.');
        }

        return $payload;
    }

    private function appleRootCaPem(): string
    {
        $path = (string) config('billing.apple_root_ca_path');
        if (! is_file($path)) {
            throw new InvalidArgumentException('File Root CA Apple tidak ditemukan.');
        }

        $pem = file_get_contents($path);
        if ($pem === false || $pem === '') {
            throw new InvalidArgumentException('File Root CA Apple tidak dapat dibaca.');
        }

        return $pem;
    }

    private function certificateToPem(string $encoded): string
    {
        $encoded = trim($encoded);
        if (str_contains($encoded, 'BEGIN CERTIFICATE')) {
            return $encoded;
        }

        return "-----BEGIN CERTIFICATE-----\n"
            .chunk_split($encoded, 64, "\n")
            ."-----END CERTIFICATE-----\n";
    }

    /**
     * @param  \OpenSSLCertificate|\OpenSSLCertificateSigningRequest|resource  $left
     * @param  \OpenSSLCertificate|\OpenSSLCertificateSigningRequest|resource  $right
     */
    private function certificateFingerprintsMatch($left, $right): bool
    {
        $leftFingerprint = openssl_x509_fingerprint($left, 'sha256');
        $rightFingerprint = openssl_x509_fingerprint($right, 'sha256');

        return is_string($leftFingerprint)
            && is_string($rightFingerprint)
            && hash_equals($leftFingerprint, $rightFingerprint);
    }

    private function ecdsaRawToDer(string $raw): string
    {
        if (strlen($raw) !== 64) {
            throw new InvalidArgumentException('Tanda tangan ES256 tidak valid.');
        }

        $r = $this->encodeInteger(substr($raw, 0, 32));
        $s = $this->encodeInteger(substr($raw, 32, 32));
        $sequence = $r.$s;

        return "\x30".$this->encodeLength(strlen($sequence)).$sequence;
    }

    private function encodeInteger(string $value): string
    {
        $value = ltrim($value, "\x00");
        if ($value === '' || (ord($value[0]) & 0x80) !== 0) {
            $value = "\x00".$value;
        }

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
        if ($decoded === false) {
            throw new InvalidArgumentException('Gagal mendecode transaksi Apple.');
        }

        return $decoded;
    }
}
