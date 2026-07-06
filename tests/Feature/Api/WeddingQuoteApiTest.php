<?php

namespace Tests\Feature\Api;

use Database\Seeders\WeddingQuoteSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WeddingQuoteApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(WeddingQuoteSeeder::class);
    }

    public function test_wedding_quotes_index_returns_active_quotes(): void
    {
        $response = $this->getJson('/api/v1/wedding-quotes');

        $response
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'quote',
                        'sort_order',
                    ],
                ],
            ]);

        $this->assertGreaterThanOrEqual(3, count($response->json('data')));

        $response->assertJsonFragment([
            'quote' => 'Dua jiwa, satu hati — awal dari kebersamaan yang indah selamanya.',
        ]);
    }
}
