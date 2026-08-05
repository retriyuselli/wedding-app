<?php

namespace Tests\Feature;

use App\Models\FamilyMember;
use App\Models\Guest;
use App\Models\User;
use App\Models\VipGuest;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TamuPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_page_shows_redesigned_layout(): void
    {
        $user = User::factory()->create();

        Guest::factory()->create([
            'user_id' => $user->id,
            'name' => 'Budi Santoso',
            'phone' => '08123456789',
            'rsvp_status' => 'hadir',
        ]);

        FamilyMember::factory()->create([
            'user_id' => $user->id,
            'name' => 'Keluarga Besar',
            'rsvp_status' => 'menunggu',
        ]);

        $response = $this->actingAs($user)->get(route('tamu'));

        $response->assertOk();
        $response->assertSee('Kelola daftar tamu undangan pernikahan Anda');
        $response->assertSee('Total Tamu');
        $response->assertSee('Statistik Tamu');
        $response->assertSee('Ringkasan per Grup');
        $response->assertSee('Budi Santoso');
        $response->assertSee('dashboard-shell', false);
    }

    public function test_guest_status_filter_limits_results(): void
    {
        $user = User::factory()->create();

        Guest::factory()->create([
            'user_id' => $user->id,
            'name' => 'Tamu Hadir',
            'rsvp_status' => 'hadir',
        ]);

        Guest::factory()->create([
            'user_id' => $user->id,
            'name' => 'Tamu Menunggu',
            'rsvp_status' => 'menunggu',
        ]);

        $response = $this->actingAs($user)->get(route('tamu', ['status' => 'akan_datang']));

        $response->assertOk();
        $response->assertSee('Tamu Hadir');
        $response->assertDontSee('Tamu Menunggu');
    }

    public function test_guest_grup_filter_limits_results(): void
    {
        $user = User::factory()->create();

        Guest::factory()->create([
            'user_id' => $user->id,
            'name' => 'Tamu Umum Satu',
        ]);

        VipGuest::factory()->create([
            'user_id' => $user->id,
            'name' => 'Tamu VIP Satu',
        ]);

        $response = $this->actingAs($user)->get(route('tamu', ['grup' => 'vip']));

        $response->assertOk();
        $response->assertSee('Tamu VIP Satu');
        $response->assertDontSee('Tamu Umum Satu');
    }
}
