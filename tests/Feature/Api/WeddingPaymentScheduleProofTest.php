<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Database\Seeders\CustomerPaymentMethodSeeder;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class WeddingPaymentScheduleProofTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('public');
        $this->seed([
            UserSeeder::class,
            CustomerPaymentMethodSeeder::class,
        ]);
    }

    public function test_store_payment_schedule_with_proof_uploads_file_and_returns_public_url(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $paymentMethodId = $user->paymentMethods()->value('id');

        $response = $this->actingAs($user, 'sanctum')
            ->post('/api/v1/wedding-payment-schedules', [
                'title' => 'DP Venue',
                'amount' => 5_000_000,
                'category' => 'venue',
                'customer_payment_method_id' => (string) $paymentMethodId,
                'proof' => UploadedFile::fake()->image('bukti.jpg')->size(500),
            ]);

        $response
            ->assertCreated()
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'proof_url',
                    'status',
                ],
            ]);

        $proofUrl = $response->json('data.proof_url');
        $this->assertNotNull($proofUrl);
        $this->assertSame('paid', $response->json('data.status'));
        $this->assertStringContainsString('/storage/payment-schedules/proofs/', $proofUrl);
        $this->assertIsInt($response->json('data.customer_payment_method_id'));
        $this->assertSame($paymentMethodId, $response->json('data.customer_payment_method_id'));

        Storage::disk('public')->assertExists(
            str_replace('/storage/', '', parse_url($proofUrl, PHP_URL_PATH))
        );
    }

    public function test_store_rejects_proof_larger_than_one_megabyte(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->post('/api/v1/wedding-payment-schedules', [
                'title' => 'DP Venue',
                'amount' => 5_000_000,
                'category' => 'venue',
                'proof' => UploadedFile::fake()->image('bukti.jpg')->size(1025),
            ]);

        $response->assertUnprocessable();
    }

    public function test_store_rejects_notes_longer_than_two_hundred_characters(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-payment-schedules', [
                'title' => 'DP Venue',
                'amount' => 5_000_000,
                'category' => 'venue',
                'notes' => str_repeat('a', 201),
            ]);

        $response->assertUnprocessable();
    }

    public function test_store_marks_expense_as_paid_when_status_is_paid(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/wedding-payment-schedules', [
                'title' => 'DP Band',
                'amount' => 5_000_000,
                'category' => 'entertainment',
                'status' => 'paid',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.status', 'paid');

        $this->assertDatabaseHas('wedding_payment_schedules', [
            'user_id' => $user->id,
            'title' => 'DP Band',
            'status' => 'paid',
        ]);

        $this->assertNotNull(
            $user->paymentSchedules()->where('title', 'DP Band')->value('paid_at')
        );
    }
}
