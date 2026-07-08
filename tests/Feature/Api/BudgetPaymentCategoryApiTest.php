<?php

namespace Tests\Feature\Api;

use App\Models\WeddingPaymentSchedule;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BudgetPaymentCategoryApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_budget_payment_categories_index_returns_all_options(): void
    {
        $response = $this->getJson('/api/v1/budget-payment-categories');

        $response
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'key',
                        'label',
                        'icon',
                    ],
                ],
                'meta' => [
                    'default_currency',
                    'default_expense_category',
                    'default_category_icon',
                    'default_expense_status',
                    'default_incoming_payment_status',
                ],
            ]);

        $this->assertSame(
            array_keys(WeddingPaymentSchedule::$categoryOptions),
            collect($response->json('data'))->pluck('key')->all()
        );

        $this->assertSame(
            'building.columns',
            collect($response->json('data'))->firstWhere('key', 'venue')['icon']
        );

        $this->assertSame(
            'Venue',
            collect($response->json('data'))->firstWhere('key', 'venue')['label']
        );

        $this->assertSame('IDR', $response->json('meta.default_currency'));
        $this->assertSame('other', $response->json('meta.default_expense_category'));
        $this->assertSame('ellipsis', $response->json('meta.default_category_icon'));
        $this->assertSame('pending', $response->json('meta.default_expense_status'));
        $this->assertSame('menunggu', $response->json('meta.default_incoming_payment_status'));
    }
}
