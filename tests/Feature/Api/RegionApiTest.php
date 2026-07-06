<?php

namespace Tests\Feature\Api;

use Tests\TestCase;

class RegionApiTest extends TestCase
{
    public function test_provinces_endpoint_returns_indonesia_provinces(): void
    {
        $response = $this->getJson('/api/v1/regions/provinces');

        $response
            ->assertOk()
            ->assertJsonStructure(['data']);

        $provinces = $response->json('data');

        $this->assertIsArray($provinces);
        $this->assertContains('Sumatera Selatan', $provinces);
        $this->assertContains('Daerah Khusus Ibukota Jakarta', $provinces);
    }

    public function test_cities_endpoint_returns_cities_for_valid_province(): void
    {
        $response = $this->getJson('/api/v1/regions/cities?province=Sumatera Selatan');

        $response
            ->assertOk()
            ->assertJsonStructure(['data']);

        $cities = $response->json('data');

        $this->assertIsArray($cities);
        $this->assertContains('Palembang', $cities);
    }

    public function test_cities_endpoint_requires_province_parameter(): void
    {
        $this->getJson('/api/v1/regions/cities')
            ->assertUnprocessable()
            ->assertJson(['message' => 'Parameter province wajib diisi.']);
    }

    public function test_cities_endpoint_returns_not_found_for_unknown_province(): void
    {
        $this->getJson('/api/v1/regions/cities?province=Provinsi Tidak Ada')
            ->assertNotFound()
            ->assertJson(['message' => 'Provinsi tidak ditemukan.']);
    }
}
