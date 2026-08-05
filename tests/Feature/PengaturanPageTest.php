<?php

namespace Tests\Feature;

use App\Models\User;
use App\Support\UserSettings;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PengaturanPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_settings_page_requires_authentication(): void
    {
        $this->get(route('pengaturan'))->assertRedirect(route('login'));
    }

    public function test_settings_page_shows_redesigned_layout(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('pengaturan'));

        $response->assertOk();
        $response->assertSee('Pengaturan (Settings)');
        $response->assertSee('Kelola preferensi aplikasi dan pengaturan akun Anda.');
        $response->assertSee('Umum');
        $response->assertSee('Notifikasi');
        $response->assertSee('Bahasa & Wilayah');
        $response->assertSee('Mode Gelap');
        $response->assertSee('Data & Penyimpanan', false);
        $response->assertSee('Ringkasan Pengaturan');
        $response->assertSee('Simpan Pengaturan');
    }

    public function test_user_can_update_general_settings(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->from(route('pengaturan'))
            ->put(route('pengaturan.update'), [
                'tab' => UserSettings::TabUmum,
                'currency' => 'IDR',
                'date_format' => 'd M Y',
                'timezone' => 'Asia/Jakarta',
                'dark_mode' => '1',
                'sound' => '1',
                'vibration' => '0',
                'auto_save' => '1',
                'show_tips' => '0',
            ])
            ->assertRedirect(route('pengaturan', ['tab' => UserSettings::TabUmum]))
            ->assertSessionHas('success');

        $user->refresh();

        $settings = UserSettings::forUser($user);

        $this->assertTrue($settings['dark_mode']);
        $this->assertFalse($settings['vibration']);
        $this->assertFalse($settings['show_tips']);
    }

    public function test_user_can_clear_cache_from_settings_page(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->from(route('pengaturan'))
            ->post(route('pengaturan.clear-cache'), [
                'tab' => UserSettings::TabUmum,
            ])
            ->assertRedirect(route('pengaturan', ['tab' => UserSettings::TabUmum]))
            ->assertSessionHas('success');
    }
}
