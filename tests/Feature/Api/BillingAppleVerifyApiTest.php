<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BillingAppleVerifyApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'billing.apple_jws_verification_bypass' => true,
        ]);
    }

    public function test_authenticated_user_can_verify_apple_purchase_in_testing_bypass_mode(): void
    {
        $user = User::factory()->create([
            'is_premium' => false,
        ]);

        $signedTransaction = $this->fakeSignedTransaction(
            productId: 'wedding_pro_unlock',
            transactionId: '2000000123456789',
            originalTransactionId: '1000000123456789',
        );

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_unlock',
                'transaction_id' => '2000000123456789',
                'original_transaction_id' => '1000000123456789',
                'signed_transaction' => $signedTransaction,
            ])
            ->assertOk()
            ->assertJsonPath('user.is_premium', true)
            ->assertJsonPath('message', 'Wedding Pro berhasil diaktifkan.');

        $user->refresh();

        $this->assertTrue($user->isPremium());
        $this->assertSame('wedding_pro_unlock', $user->premium_product_id);
        $this->assertSame('1000000123456789', $user->apple_original_transaction_id);
    }

    public function test_verify_transfers_pro_to_current_account_when_apple_purchase_was_on_another_account(): void
    {
        $previousOwner = User::factory()->create([
            'email' => 'previous-owner@example.com',
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'premium_activated_at' => now()->subDay(),
            'apple_original_transaction_id' => '1000000123456789',
        ]);

        $currentUser = User::factory()->create([
            'email' => 'current-user@example.com',
            'is_premium' => false,
        ]);

        $signedTransaction = $this->fakeSignedTransaction(
            productId: 'wedding_pro_unlock',
            transactionId: '2000000123456789',
            originalTransactionId: '1000000123456789',
        );

        $this->actingAs($currentUser, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_unlock',
                'transaction_id' => '2000000123456789',
                'original_transaction_id' => '1000000123456789',
                'signed_transaction' => $signedTransaction,
            ])
            ->assertOk()
            ->assertJsonPath('user.is_premium', true)
            ->assertJsonPath('message', 'Wedding Pro berhasil dipulihkan ke akun ini.');

        $previousOwner->refresh();
        $currentUser->refresh();

        $this->assertFalse($previousOwner->isPremium());
        $this->assertNull($previousOwner->apple_original_transaction_id);
        $this->assertTrue($currentUser->isPremium());
        $this->assertSame('1000000123456789', $currentUser->apple_original_transaction_id);
    }

    public function test_verify_is_idempotent_for_same_account(): void
    {
        $user = User::factory()->create([
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'premium_activated_at' => now()->subHour(),
            'apple_original_transaction_id' => '1000000123456789',
        ]);

        $signedTransaction = $this->fakeSignedTransaction(
            productId: 'wedding_pro_unlock',
            transactionId: '2000000123456789',
            originalTransactionId: '1000000123456789',
        );

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_unlock',
                'transaction_id' => '2000000123456789',
                'original_transaction_id' => '1000000123456789',
                'signed_transaction' => $signedTransaction,
            ])
            ->assertOk()
            ->assertJsonPath('message', 'Wedding Pro sudah aktif.')
            ->assertJsonPath('user.is_premium', true);
    }

    public function test_verify_rejects_mismatched_product_id(): void
    {
        $user = User::factory()->create();

        $signedTransaction = $this->fakeSignedTransaction(
            productId: 'other_product',
            transactionId: '2000000123456789',
            originalTransactionId: '1000000123456789',
        );

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_unlock',
                'transaction_id' => '2000000123456789',
                'original_transaction_id' => '1000000123456789',
                'signed_transaction' => $signedTransaction,
            ])
            ->assertUnprocessable();
    }

    public function test_verify_rejects_unsigned_payload_when_bypass_disabled(): void
    {
        config([
            'billing.apple_jws_verification_bypass' => false,
        ]);

        $user = User::factory()->create();

        $signedTransaction = $this->fakeSignedTransaction(
            productId: 'wedding_pro_unlock',
            transactionId: '2000000123456789',
            originalTransactionId: '1000000123456789',
        );

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_unlock',
                'transaction_id' => '2000000123456789',
                'original_transaction_id' => '1000000123456789',
                'signed_transaction' => $signedTransaction,
            ])
            ->assertUnprocessable();
    }

    public function test_verify_accepts_storekit_testing_zero_transaction_ids(): void
    {
        $user = User::factory()->create([
            'is_premium' => false,
        ]);

        $signedTransaction = $this->fakeSignedTransaction(
            productId: 'wedding_pro_unlock',
            transactionId: '0',
            originalTransactionId: '0',
            extraClaims: [
                'purchaseDate' => 1720000000000,
                'webOrderLineItemId' => 'storekit-test-order-1',
            ],
        );

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_unlock',
                'transaction_id' => '0',
                'original_transaction_id' => '0',
                'signed_transaction' => $signedTransaction,
            ])
            ->assertOk()
            ->assertJsonPath('user.is_premium', true);

        $user->refresh();

        $this->assertTrue($user->isPremium());
        $this->assertNotNull($user->apple_original_transaction_id);
        $this->assertNotSame('0', $user->apple_original_transaction_id);
        $this->assertStringStartsWith('sk_', (string) $user->apple_original_transaction_id);
    }

    public function test_subscription_sets_an_expiry_and_lifetime_does_not(): void
    {
        $user = User::factory()->create([
            'is_premium' => false,
        ]);

        $expiresAt = now()->addMonth()->startOfSecond();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_monthly',
                'transaction_id' => '2000000999000001',
                'original_transaction_id' => '1000000999000001',
                'signed_transaction' => $this->fakeSignedTransaction(
                    productId: 'wedding_pro_monthly',
                    transactionId: '2000000999000001',
                    originalTransactionId: '1000000999000001',
                    extraClaims: ['expiresDate' => $expiresAt->getTimestampMs()],
                ),
            ])
            ->assertOk()
            ->assertJsonPath('user.is_premium', true);

        $user->refresh();

        $this->assertTrue($user->isPremium());
        $this->assertSame('wedding_pro_monthly', $user->premium_product_id);
        $this->assertNotNull($user->premium_expires_at);
        $this->assertTrue($user->premium_expires_at->equalTo($expiresAt));
    }

    public function test_expired_subscription_is_rejected(): void
    {
        $user = User::factory()->create([
            'is_premium' => false,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/billing/apple/verify', [
                'product_id' => 'wedding_pro_monthly',
                'transaction_id' => '2000000999000002',
                'original_transaction_id' => '1000000999000002',
                'signed_transaction' => $this->fakeSignedTransaction(
                    productId: 'wedding_pro_monthly',
                    transactionId: '2000000999000002',
                    originalTransactionId: '1000000999000002',
                    extraClaims: ['expiresDate' => now()->subDay()->getTimestampMs()],
                ),
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['original_transaction_id']);

        $this->assertFalse($user->fresh()->isPremium());
    }

    private function fakeSignedTransaction(
        string $productId,
        string $transactionId,
        string $originalTransactionId,
        array $extraClaims = [],
    ): string {
        $header = $this->base64UrlEncode(json_encode(['alg' => 'ES256'], JSON_THROW_ON_ERROR));
        $payload = $this->base64UrlEncode(json_encode(array_merge([
            'productId' => $productId,
            'transactionId' => $transactionId,
            'originalTransactionId' => $originalTransactionId,
            'bundleId' => 'com.weddingapp.ios',
        ], $extraClaims), JSON_THROW_ON_ERROR));

        return $header.'.'.$payload.'.'.$this->base64UrlEncode('fake-signature');
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
