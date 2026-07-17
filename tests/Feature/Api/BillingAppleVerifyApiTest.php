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
            ->assertJsonPath('user.is_premium', true);

        $user->refresh();

        $this->assertTrue($user->isPremium());
        $this->assertSame('wedding_pro_unlock', $user->premium_product_id);
        $this->assertSame('1000000123456789', $user->apple_original_transaction_id);
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

    private function fakeSignedTransaction(
        string $productId,
        string $transactionId,
        string $originalTransactionId,
    ): string {
        $header = $this->base64UrlEncode(json_encode(['alg' => 'ES256'], JSON_THROW_ON_ERROR));
        $payload = $this->base64UrlEncode(json_encode([
            'productId' => $productId,
            'transactionId' => $transactionId,
            'originalTransactionId' => $originalTransactionId,
            'bundleId' => 'com.weddingapp.ios',
        ], JSON_THROW_ON_ERROR));

        return $header.'.'.$payload.'.'.$this->base64UrlEncode('fake-signature');
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
