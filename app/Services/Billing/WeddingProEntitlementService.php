<?php

namespace App\Services\Billing;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use InvalidArgumentException;

class WeddingProEntitlementService
{
    /**
     * Activate Wedding Pro for the current user from a verified Apple transaction.
     *
     * Non-Consumable purchases belong to the Apple ID. A verified StoreKit JWS is
     * treated as proof of ownership: if the same entitlement key was linked to
     * another Wedding App account, Pro is moved to the account that is signing in
     * now (restore / re-login on a new account).
     *
     * @param  array{
     *     product_id: string,
     *     transaction_id: string,
     *     original_transaction_id: string,
     *     payload?: array<string, mixed>
     * }  $verified
     * @return array{user: User, message: string, transferred_from_user_id: int|null}
     */
    public function activateFromVerifiedAppleTransaction(
        User $user,
        array $verified,
        string $signedTransaction,
    ): array {
        $productId = $verified['product_id'];
        $payload = is_array($verified['payload'] ?? null) ? $verified['payload'] : [];
        $entitlementKey = $this->resolveEntitlementKey($verified, $payload, $signedTransaction);

        if (! in_array($productId, config('billing.pro_product_ids', []), true)) {
            throw new InvalidArgumentException('Produk tidak dikenali sebagai Wedding Pro.');
        }

        return DB::transaction(function () use ($user, $entitlementKey, $productId): array {
            /** @var User $user */
            $user = User::query()->whereKey($user->id)->lockForUpdate()->firstOrFail();

            $owner = User::query()
                ->where('apple_original_transaction_id', $entitlementKey)
                ->lockForUpdate()
                ->first();

            $transferredFromUserId = null;

            if ($owner && $owner->id !== $user->id) {
                $transferredFromUserId = $owner->id;
                $this->revokeAppleLinkedPro($owner);

                Log::info('Wedding Pro entitlement transferred between accounts', [
                    'entitlement_key' => $entitlementKey,
                    'from_user_id' => $transferredFromUserId,
                    'to_user_id' => $user->id,
                ]);
            }

            if ($user->isPremium()
                && $user->apple_original_transaction_id === $entitlementKey) {
                return [
                    'user' => $user->fresh(),
                    'message' => 'Wedding Pro sudah aktif.',
                    'transferred_from_user_id' => $transferredFromUserId,
                ];
            }

            $user->forceFill([
                'is_premium' => true,
                'premium_product_id' => $productId,
                'premium_activated_at' => $user->premium_activated_at ?? now(),
                'apple_original_transaction_id' => $entitlementKey,
            ])->save();

            $message = $transferredFromUserId !== null
                ? 'Wedding Pro berhasil dipulihkan ke akun ini.'
                : 'Wedding Pro berhasil diaktifkan.';

            return [
                'user' => $user->fresh(),
                'message' => $message,
                'transferred_from_user_id' => $transferredFromUserId,
            ];
        });
    }

    /**
     * Prefer real Apple transaction IDs; never persist literal "0".
     * StoreKit Testing often emits 0 — fall back to stable payload claims / JWS hash.
     *
     * @param  array{product_id: string, transaction_id: string, original_transaction_id: string}  $verified
     * @param  array<string, mixed>  $payload
     */
    public function resolveEntitlementKey(array $verified, array $payload, string $signedTransaction): string
    {
        foreach ([
            (string) ($verified['original_transaction_id'] ?? ''),
            (string) ($verified['transaction_id'] ?? ''),
        ] as $candidate) {
            if ($this->isUsableAppleTransactionId($candidate)) {
                return $candidate;
            }
        }

        $productId = (string) ($payload['productId'] ?? $verified['product_id'] ?? '');
        $purchaseDate = (string) ($payload['purchaseDate'] ?? $payload['originalPurchaseDate'] ?? '');
        $webOrderLineItemId = (string) ($payload['webOrderLineItemId'] ?? '');
        $deviceVerification = (string) ($payload['deviceVerification'] ?? '');

        $stableParts = array_values(array_filter(
            [$productId, $purchaseDate, $webOrderLineItemId, $deviceVerification],
            fn (string $value): bool => $value !== '',
        ));

        if ($stableParts !== []) {
            return 'sk_'.hash('sha256', implode('|', $stableParts));
        }

        // Last resort: unique per signed blob (still better than colliding on "0").
        return 'jws_'.hash('sha256', $signedTransaction);
    }

    public function isUsableAppleTransactionId(string $originalTransactionId): bool
    {
        $normalized = trim($originalTransactionId);

        if ($normalized === '' || $normalized === '0' || preg_match('/^0+$/', $normalized) === 1) {
            return false;
        }

        // Guard against accidental placeholders from admin/demo mistakes.
        if (in_array(strtolower($normalized), ['null', 'undefined', 'n/a', 'na'], true)) {
            return false;
        }

        return true;
    }

    public function revokeAppleLinkedPro(User $user): void
    {
        $user->forceFill([
            'is_premium' => false,
            'premium_product_id' => null,
            'premium_activated_at' => null,
            'apple_original_transaction_id' => null,
        ])->save();
    }
}
