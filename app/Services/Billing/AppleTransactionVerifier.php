<?php

namespace App\Services\Billing;

use InvalidArgumentException;

class AppleTransactionVerifier
{
    /**
     * Decode and lightly validate a StoreKit 2 signed transaction JWS.
     *
     * @return array{product_id: string, transaction_id: string, original_transaction_id: string}
     */
    public function verify(string $signedTransaction, string $expectedProductId, string $expectedTransactionId, string $expectedOriginalTransactionId): array
    {
        $parts = explode('.', $signedTransaction);
        if (count($parts) !== 3) {
            throw new InvalidArgumentException('Format transaksi Apple tidak valid.');
        }

        $payloadJson = $this->base64UrlDecode($parts[1]);
        $payload = json_decode($payloadJson, true);

        if (! is_array($payload)) {
            throw new InvalidArgumentException('Payload transaksi Apple tidak valid.');
        }

        $productId = (string) ($payload['productId'] ?? '');
        $transactionId = (string) ($payload['transactionId'] ?? '');
        $originalTransactionId = (string) ($payload['originalTransactionId'] ?? $transactionId);

        if ($productId === '' || $transactionId === '') {
            throw new InvalidArgumentException('Transaksi Apple tidak lengkap.');
        }

        if ($productId !== $expectedProductId) {
            throw new InvalidArgumentException('Product ID tidak cocok.');
        }

        if ($transactionId !== $expectedTransactionId) {
            throw new InvalidArgumentException('Transaction ID tidak cocok.');
        }

        if ($originalTransactionId !== $expectedOriginalTransactionId) {
            throw new InvalidArgumentException('Original transaction ID tidak cocok.');
        }

        if (! in_array($productId, config('billing.pro_product_ids', []), true)) {
            throw new InvalidArgumentException('Produk tidak dikenali sebagai Wedding Pro.');
        }

        return [
            'product_id' => $productId,
            'transaction_id' => $transactionId,
            'original_transaction_id' => $originalTransactionId,
        ];
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
