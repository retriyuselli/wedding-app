<?php

namespace Tests\Feature\Api;

use Database\Seeders\CategorySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoryApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(CategorySeeder::class);
    }

    public function test_categories_index_returns_active_wedding_categories(): void
    {
        $response = $this->getJson('/api/v1/categories');

        $response
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'slug',
                        'icon',
                        'description',
                        'sort_order',
                    ],
                ],
            ]);

        $this->assertGreaterThanOrEqual(20, count($response->json('data')));

        $response->assertJsonFragment([
            'slug' => 'wedding-organizer',
            'name' => 'Wedding Organizer',
        ]);

        $response->assertJsonFragment([
            'slug' => 'venue',
            'name' => 'Venue',
        ]);
    }
}
