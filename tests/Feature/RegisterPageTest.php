<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegisterPageTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.google.client_id' => 'test-web-client.apps.googleusercontent.com',
            'services.apple.client_id' => 'com.weddingapp.web',
        ]);
    }

    public function test_register_page_shows_redesigned_layout(): void
    {
        $response = $this->get(route('register'));

        $response->assertOk();
        $response->assertSee('Buat Akun Baru');
        $response->assertSee('Teman terbaik dalam merencanakan hari bahagia Anda.');
        $response->assertSee('Merencanakan hari bahagiamu jadi lebih mudah', false);
        $response->assertSee('Masukkan nama lengkap');
        $response->assertSee('Ulangi kata sandi');
        $response->assertSee('atau daftar dengan');
        $response->assertSee('toggle-password-confirmation', false);
        $response->assertSee('Privasi & Aman', false);
        $response->assertSee('Masuk di sini');
        $response->assertSee('font-family: "Poppins"', false);
    }

    public function test_user_can_register_from_redesigned_form(): void
    {
        $response = $this->post(route('register'), [
            'name' => 'Pengantin Baru',
            'email' => 'baru@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertRedirect(route('dashboard'));
        $this->assertAuthenticated();

        $this->assertDatabaseHas('users', [
            'name' => 'Pengantin Baru',
            'email' => 'baru@example.com',
        ]);
    }
}
