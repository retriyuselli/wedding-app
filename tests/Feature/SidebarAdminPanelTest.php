<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class SidebarAdminPanelTest extends TestCase
{
    use RefreshDatabase;

    public function test_super_admin_sees_admin_panel_link_in_desktop_sidebar(): void
    {
        Role::create([
            'name' => config('filament-shield.super_admin.name', 'super_admin'),
            'guard_name' => 'web',
        ]);

        $user = User::factory()->create();
        $user->assignRole(config('filament-shield.super_admin.name', 'super_admin'));

        $response = $this->actingAs($user)->get(route('dashboard'));

        $response->assertOk();
        $response->assertSee('Admin Panel', false);
        $response->assertSee('/admin', false);
    }

    public function test_regular_user_does_not_see_admin_panel_link(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('dashboard'));

        $response->assertOk();
        $response->assertDontSee('Admin Panel', false);
    }
}
