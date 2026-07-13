<?php

namespace Tests\Feature;

use App\Filament\Resources\Users\Pages\CreateUser;
use App\Filament\Resources\Users\Pages\EditUser;
use App\Filament\Resources\Users\Pages\ListUsers;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Livewire\Livewire;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class UserResourceFormTest extends TestCase
{
    use RefreshDatabase;

    public function test_super_admin_can_open_create_user_page(): void
    {
        $admin = $this->actingAsSuperAdmin();

        Livewire::actingAs($admin)
            ->test(CreateUser::class)
            ->assertSuccessful()
            ->assertSee('Informasi Akun')
            ->assertSee('Keamanan')
            ->assertSee('Role & Akses')
            ->assertSee('Konfirmasi Password');
    }

    public function test_super_admin_can_open_edit_user_page(): void
    {
        $admin = $this->actingAsSuperAdmin();
        $user = User::factory()->create([
            'name' => 'Pengantin Contoh',
            'whatsapp' => '081234567890',
        ]);

        Livewire::actingAs($admin)
            ->test(EditUser::class, ['record' => $user->getRouteKey()])
            ->assertSuccessful()
            ->assertSee('Pengantin Contoh')
            ->assertSee('Login Sosial')
            ->assertSee('Biarkan kosong untuk mempertahankan password saat ini.');
    }

    public function test_password_cast_hashes_once_without_manual_hash_make(): void
    {
        $user = User::factory()->create([
            'password' => 'plain-password-123',
        ]);

        $this->assertTrue(Hash::check('plain-password-123', $user->fresh()->password));
        $this->assertFalse(Hash::check('plain-password-123', Hash::make($user->fresh()->password)));
    }

    public function test_users_index_shows_improved_columns(): void
    {
        $admin = $this->actingAsSuperAdmin();
        User::factory()->create([
            'name' => 'User List Check',
            'email' => 'userlist@example.com',
        ]);

        Livewire::actingAs($admin)
            ->test(ListUsers::class)
            ->assertSuccessful()
            ->assertSee('User List Check')
            ->assertSee('Pengguna')
            ->assertSee('Bergabung')
            ->assertCanSeeTableRecords(User::query()->where('email', 'userlist@example.com')->get());
    }

    public function test_regular_user_cannot_access_admin_panel(): void
    {
        $user = User::factory()->create();

        $this->assertFalse($user->canAccessPanel(Filament::getPanel('admin')));

        $response = $this->actingAs($user)->get('/admin');

        $response->assertForbidden();
    }

    private function actingAsSuperAdmin(): User
    {
        $role = Role::findOrCreate(config('filament-shield.super_admin.name', 'super_admin'), 'web');

        foreach ([
            'ViewAny:User',
            'View:User',
            'Create:User',
            'Update:User',
            'Delete:User',
            'DeleteAny:User',
        ] as $permissionName) {
            $permission = Permission::findOrCreate($permissionName, 'web');
            $role->givePermissionTo($permission);
        }

        $admin = User::factory()->create([
            'email' => 'superadmin-userform@example.com',
        ]);
        $admin->assignRole($role);

        return $admin;
    }
}
