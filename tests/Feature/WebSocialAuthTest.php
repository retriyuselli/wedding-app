<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class WebSocialAuthTest extends TestCase
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

    public function test_login_page_shows_social_buttons_when_configured(): void
    {
        $response = $this->get(route('login'));

        $response->assertOk();
        $response->assertSee('id="google-signin-button"', false);
        $response->assertSee('id="apple-signin-button"', false);
        $response->assertSee('accounts.google.com/gsi/client', false);
        $response->assertSee('appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js', false);
    }

    public function test_register_page_shows_social_buttons_when_configured(): void
    {
        $response = $this->get(route('register'));

        $response->assertOk();
        $response->assertSee('Buat Akun Baru');
        $response->assertSee('atau daftar dengan');
        $response->assertSee('id="google-signin-button"', false);
        $response->assertSee('id="apple-signin-button"', false);
    }

    public function test_web_google_auth_logs_user_in(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'sub' => 'google-web-123',
                'email' => 'web.google@example.com',
                'name' => 'Web Google User',
                'aud' => 'test-web-client.apps.googleusercontent.com',
                'email_verified' => 'true',
            ]),
        ]);

        $response = $this->post(route('auth.google'), [
            'credential' => 'valid-google-token',
        ]);

        $response->assertRedirect(route('dashboard'));
        $this->assertAuthenticated();

        $this->assertDatabaseHas('users', [
            'email' => 'web.google@example.com',
            'google_id' => 'google-web-123',
        ]);
    }

    public function test_social_buttons_hidden_when_credentials_are_missing(): void
    {
        config([
            'services.google.client_id' => null,
            'services.apple.client_id' => null,
        ]);

        $response = $this->get(route('login'));

        $response->assertOk();
        $response->assertDontSee('id="google-signin-button"', false);
        $response->assertDontSee('id="apple-signin-button"', false);
        $response->assertDontSee('atau masuk dengan');
    }
}
