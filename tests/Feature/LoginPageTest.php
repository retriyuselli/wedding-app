<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoginPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_page_shows_redesigned_layout(): void
    {
        $response = $this->get(route('login'));

        $response->assertOk();
        $response->assertSee('Selamat Datang Kembali!');
        $response->assertSee('Merencanakan hari bahagiamu jadi lebih mudah', false);
        $response->assertSee('Masukkan email');
        $response->assertSee('atau masuk dengan');
        $response->assertSee('Privasi & Aman', false);
        $response->assertSee('Bantuan 24/7');
        $response->assertSee('Daftar sekarang');
    }

    public function test_user_can_login_from_redesigned_form(): void
    {
        $user = User::factory()->create([
            'password' => 'password123',
        ]);

        $response = $this->post(route('login'), [
            'email' => $user->email,
            'password' => 'password123',
        ]);

        $response->assertRedirect(route('dashboard'));
        $this->assertAuthenticatedAs($user);
    }
}
