<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\WeddingInfo;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BantuanPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_help_page_requires_authentication(): void
    {
        $this->get(route('bantuan'))->assertRedirect(route('login'));
    }

    public function test_help_page_shows_redesigned_layout(): void
    {
        $user = User::factory()
            ->has(WeddingInfo::factory()->state([
                'groom_name' => 'Rama',
                'bride_name' => 'Anya',
            ]))
            ->create();

        $response = $this->actingAs($user)->get(route('bantuan'));

        $response->assertOk();
        $response->assertSee('Bantuan & FAQ');
        $response->assertSee('Temukan jawaban cepat atau hubungi kami jika membutuhkan bantuan.');
        $response->assertSee('Pertanyaan yang Sering Diajukan');
        $response->assertSee('Topik Bantuan');
        $response->assertSee('Hubungi Kami');
        $response->assertSee('Panduan Populer');
        $response->assertSee('Informasi Aplikasi');
        $response->assertSee('Bagaimana cara menambahkan tamu ke daftar guest?');
        $response->assertSee('Memulai');
        $response->assertSee('support@weddingapp.co.id');
        $response->assertSee('Masih butuh bantuan?');
    }

    public function test_help_page_can_filter_faqs_by_search(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('bantuan', ['q' => 'menghapus akun']));

        $response->assertOk();
        $response->assertSee('Bagaimana cara menghapus akun saya?');
        $response->assertDontSee('Bagaimana cara menambahkan tamu ke daftar guest?');
    }
}
