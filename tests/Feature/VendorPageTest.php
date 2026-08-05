<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VendorPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_vendor_page_shows_redesigned_layout(): void
    {
        $user = User::factory()->create();

        $category = Category::factory()->create([
            'name' => 'Venue',
            'slug' => 'venue',
            'is_active' => true,
        ]);

        Vendor::factory()->create([
            'category_id' => $category->id,
            'name' => 'Aston Palembang Hotel',
            'slug' => 'aston-palembang-hotel',
            'city' => 'Palembang',
            'is_active' => true,
            'is_featured' => true,
        ]);

        $response = $this->actingAs($user)->get(route('vendor'));

        $response->assertOk();
        $response->assertSee('Temukan dan kelola semua vendor terbaik');
        $response->assertSee('Ringkasan Vendor');
        $response->assertSee('Rating Rata-Rata');
        $response->assertSee('Aston Palembang Hotel');
        $response->assertSee('dashboard-shell', false);
    }

    public function test_vendor_category_filter_limits_results(): void
    {
        $user = User::factory()->create();

        $venueCategory = Category::factory()->create(['slug' => 'venue', 'name' => 'Venue']);
        $cateringCategory = Category::factory()->create(['slug' => 'catering', 'name' => 'Catering']);

        Vendor::factory()->create([
            'category_id' => $venueCategory->id,
            'name' => 'Venue Vendor',
            'slug' => 'venue-vendor',
            'is_active' => true,
        ]);

        Vendor::factory()->create([
            'category_id' => $cateringCategory->id,
            'name' => 'Catering Vendor',
            'slug' => 'catering-vendor',
            'is_active' => true,
        ]);

        $response = $this->actingAs($user)->get(route('vendor', ['category' => 'venue']));

        $response->assertOk();
        $response->assertSee('Venue Vendor');
        $response->assertDontSee('Catering Vendor');
    }

    public function test_vendor_favorite_toggle_stores_in_session(): void
    {
        $user = User::factory()->create();

        $vendor = Vendor::factory()->create([
            'category_id' => Category::factory()->create()->id,
            'is_active' => true,
        ]);

        $response = $this->actingAs($user)
            ->post(route('vendor.favorite', $vendor->id));

        $response->assertRedirect();
        $this->assertEquals([$vendor->id], session('favorite_vendors'));
    }
}
