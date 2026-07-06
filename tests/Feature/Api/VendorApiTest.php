<?php

namespace Tests\Feature\Api;

use Database\Seeders\CategorySeeder;
use Database\Seeders\VendorPackageSeeder;
use Database\Seeders\VendorSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VendorApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([
            CategorySeeder::class,
            VendorSeeder::class,
            VendorPackageSeeder::class,
        ]);
    }

    public function test_vendors_index_returns_active_vendors_with_package_summary(): void
    {
        $response = $this->getJson('/api/v1/vendors');

        $response
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'slug',
                        'province',
                        'city',
                        'is_verified',
                        'category',
                        'packages_count',
                        'starting_price',
                    ],
                ],
            ]);

        $grandBallroom = collect($response->json('data'))
            ->firstWhere('slug', 'grand-ballroom');

        $this->assertNotNull($grandBallroom);
        $this->assertSame(3, $grandBallroom['packages_count']);
        $this->assertSame('35000000.00', $grandBallroom['starting_price']);
    }

    public function test_vendors_index_can_filter_by_category_slug(): void
    {
        $response = $this->getJson('/api/v1/vendors?category=fotografi');

        $response->assertOk();

        $slugs = collect($response->json('data'))->pluck('slug')->all();

        $this->assertContains('dewa-photography', $slugs);
        $this->assertContains('frame-story-studio', $slugs);
        $this->assertNotContains('grand-ballroom', $slugs);
    }

    public function test_vendor_show_returns_vendor_with_packages(): void
    {
        $response = $this->getJson('/api/v1/vendors/grand-ballroom');

        $response
            ->assertOk()
            ->assertJsonPath('data.slug', 'grand-ballroom')
            ->assertJsonPath('data.category.slug', 'venue')
            ->assertJsonCount(3, 'data.packages');
    }

    public function test_vendor_show_returns_not_found_for_unknown_slug(): void
    {
        $this->getJson('/api/v1/vendors/tidak-ada')
            ->assertNotFound()
            ->assertJson(['message' => 'Vendor tidak ditemukan.']);
    }

    public function test_vendor_packages_endpoint_returns_active_packages(): void
    {
        $response = $this->getJson('/api/v1/vendors/dewa-photography/packages');

        $response
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'slug',
                        'price',
                        'price_type',
                        'inclusions',
                        'facility_sections',
                    ],
                ],
            ]);
    }

    public function test_vendor_show_includes_grouped_facility_sections(): void
    {
        $response = $this->getJson('/api/v1/vendors/grand-ballroom');

        $response
            ->assertOk()
            ->assertJsonPath('data.packages.1.slug', 'paket-premium')
            ->assertJsonPath('data.packages.1.facility_sections.0.title', 'Dekorasi by Hj. Nila, Naraya, PPM 2')
            ->assertJsonPath('data.packages.1.facility_sections.4.title', 'Lain-Lain');
    }
}
