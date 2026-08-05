<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\WeddingIncomingPayment;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WeddingIncomingPaymentApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(UserSeeder::class);
    }

    public function test_user_can_create_update_and_delete_incoming_payment(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $createResponse = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-incoming-payments', [
                'sender_name' => 'Budi Santoso',
                'amount' => 1_500_000,
                'transfer_date' => '2026-07-01',
                'bank_name' => 'BCA',
                'status' => 'menunggu',
            ]);

        $createResponse
            ->assertCreated()
            ->assertJsonPath('data.sender_name', 'Budi Santoso')
            ->assertJsonPath('data.status', 'menunggu');

        $paymentId = $createResponse->json('data.id');

        $updateResponse = $this->actingAs($user, 'sanctum')
            ->putJson("/api/v1/wedding-incoming-payments/{$paymentId}", [
                'sender_name' => 'Budi Santoso',
                'amount' => 2_000_000,
                'transfer_date' => '2026-07-02',
                'status' => 'confirmed',
            ]);

        $updateResponse
            ->assertOk()
            ->assertJsonPath('data.status', 'confirmed');

        $this->assertSame(2_000_000.0, (float) $updateResponse->json('data.amount'));

        $this->assertNotNull(
            WeddingIncomingPayment::query()->findOrFail($paymentId)->confirmed_at
        );

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/wedding-incoming-payments/{$paymentId}")
            ->assertNoContent();

        $this->assertDatabaseMissing('wedding_incoming_payments', ['id' => $paymentId]);
    }

    public function test_user_cannot_access_another_users_incoming_payment(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $otherUser = User::factory()->create();

        $payment = WeddingIncomingPayment::factory()->for($owner)->create();

        $this->actingAs($otherUser, 'sanctum')
            ->putJson("/api/v1/wedding-incoming-payments/{$payment->id}", [
                'sender_name' => 'Intruder',
                'amount' => 100,
                'transfer_date' => '2026-07-01',
                'status' => 'confirmed',
            ])
            ->assertNotFound();

        $this->actingAs($otherUser, 'sanctum')
            ->deleteJson("/api/v1/wedding-incoming-payments/{$payment->id}")
            ->assertNotFound();
    }
}
