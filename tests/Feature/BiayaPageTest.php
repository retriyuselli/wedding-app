<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\WeddingBudget;
use App\Models\WeddingBudgetCategoryAllocation;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BiayaPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_budget_page_shows_redesigned_layout(): void
    {
        $user = User::factory()->create();

        WeddingBudget::factory()->create([
            'user_id' => $user->id,
            'total_budget' => 150000000,
        ]);

        WeddingBudgetCategoryAllocation::factory()->create([
            'user_id' => $user->id,
            'category' => 'venue',
            'allocated_amount' => 45000000,
        ]);

        WeddingPaymentSchedule::factory()->create([
            'user_id' => $user->id,
            'title' => 'Pembayaran DP Venue',
            'vendor_name' => 'Aston Palembang',
            'category' => 'venue',
            'amount' => 15000000,
            'status' => 'paid',
            'paid_at' => now(),
        ]);

        $response = $this->actingAs($user)->get(route('biaya'));

        $response->assertOk();
        $response->assertSee('Pantau anggaran pernikahan dan pengeluaran Anda');
        $response->assertSee('Total Anggaran');
        $response->assertSee('Ringkasan Grafik');
        $response->assertSee('Transaksi Terbaru');
        $response->assertSee('Pembayaran DP Venue');
        $response->assertSee('dashboard-shell', false);
    }

    public function test_budget_transactions_tab_shows_payment_schedules(): void
    {
        $user = User::factory()->create();

        WeddingPaymentSchedule::factory()->create([
            'user_id' => $user->id,
            'title' => 'Pelunasan Catering',
            'status' => 'pending',
        ]);

        $response = $this->actingAs($user)->get(route('biaya', ['tab' => 'transaksi']));

        $response->assertOk();
        $response->assertSee('Pelunasan Catering');
    }

    public function test_budget_page_shows_empty_state_when_no_categories(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('biaya'));

        $response->assertOk();
        $response->assertSee('Belum ada kategori anggaran.');
        $response->assertSee('Atur total anggaran');
        $response->assertDontSee('Rp 45.000.000', false);
        $response->assertDontSee('Rp 28.000.000', false);
    }
}
