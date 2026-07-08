<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_is_redirected_from_home_to_login(): void
    {
        $response = $this->get('/');

        $response->assertRedirect(route('login'));
    }

    public function test_authenticated_user_can_access_dashboard(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get('/');

        $response->assertOk();
        $response->assertSee('Hari Pernikahan');
        $response->assertSee('Persiapan Keseluruhan');
        $response->assertSee('Vendor Terbaru');
        $response->assertSee('Anggaran per Kategori');
        $response->assertSee('Cuaca Pernikahan');
        $response->assertSee('Tips Hari Ini');
        $response->assertSee('dashboard-shell', false);
        $response->assertSee('Wedding App', false);
    }
}
