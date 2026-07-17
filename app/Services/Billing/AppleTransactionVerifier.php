<?php

namespace App\Services\Billing;

use InvalidArgumentException;

class AppleTransactionVerifier
{
    public function __construct(
        private AppleStoreKitJwsVerifier $jwsVerifier,
    ) {}

    /**
     * Verify a StoreKit 2 signed transaction JWS and return normalized transaction data.
     *
     * @return array{product_id: string, transaction_id: string, original_transaction_id: string}
     */
    public function verify(
        string $signedTransaction,
        string $expectedProductId,
        string $expectedTransactionId,
        string $expectedOriginalTransactionId,
    ): array {
        $payload = $this->jwsVerifier->verify($signedTransaction);

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
}
