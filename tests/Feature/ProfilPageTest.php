<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\WeddingInfo;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfilPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_profile_page_requires_authentication(): void
    {
        $this->get(route('profil'))->assertRedirect(route('login'));
    }

    public function test_profile_page_shows_redesigned_layout(): void
    {
        $user = User::factory()
            ->has(WeddingInfo::factory()->state([
                'groom_name' => 'Rama',
                'bride_name' => 'Anya',
            ]))
            ->create([
                'name' => 'Rama Test',
                'email' => 'rama@example.com',
                'whatsapp' => '081234567890',
            ]);

        $response = $this->actingAs($user)->get(route('profil'));

        $response->assertOk();
        $response->assertSee('Profil Saya');
        $response->assertSee('Halo Rama & Anya');
        $response->assertSee('Progres Checklist');
        $response->assertSee('Ringkasan Budget');
        $response->assertSee('Tugas Mendatang');
        $response->assertSee('Vendor Terbaru');
        $response->assertSee('Pengaturan Akun');
        $response->assertSee('Premium Plan');
        $response->assertSee('Keluar Akun');
        $response->assertSee('rama@example.com');
        $response->assertSee('Informasi Akun', false);
        $response->assertSee('Detail Pernikahan', false);
    }

    public function test_user_can_update_profile_from_profile_page(): void
    {
        $user = User::factory()->create([
            'name' => 'Old Name',
            'email' => 'old@example.com',
        ]);

        $this->actingAs($user)
            ->from(route('profil'))
            ->put(route('profil.update'), [
                'name' => 'New Name',
                'email' => 'new@example.com',
                'whatsapp' => '081111111111',
            ])
            ->assertRedirect(route('profil'))
            ->assertSessionHas('success_profile');

        $user->refresh();

        $this->assertSame('New Name', $user->name);
        $this->assertSame('new@example.com', $user->email);
        $this->assertSame('081111111111', $user->whatsapp);
    }

    public function test_user_can_update_wedding_info_from_profile_page(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->from(route('profil'))
            ->put(route('profil.wedding'), [
                'groom_name' => 'Budi',
                'bride_name' => 'Sari',
                'budaya' => 'Jawa',
            ])
            ->assertRedirect(route('profil'))
            ->assertSessionHas('success_wedding');

        $this->assertDatabaseHas(WeddingInfo::class, [
            'user_id' => $user->id,
            'groom_name' => 'Budi',
            'bride_name' => 'Sari',
            'budaya' => 'Jawa',
        ]);
    }
}
