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
            ->assertSee('Wedding Pro')
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
            ->assertSee('Wedding Pro')
            ->assertSee('Biarkan kosong untuk mempertahankan password saat ini.');
    }

    public function test_super_admin_can_activate_wedding_pro_from_edit_form(): void
    {
        $admin = $this->actingAsSuperAdmin();
        $user = User::factory()->create([
            'email' => 'pro-form@example.com',
            'is_premium' => false,
        ]);

        Livewire::actingAs($admin)
            ->test(EditUser::class, ['record' => $user->getRouteKey()])
            ->fillForm([
                'is_premium' => true,
                'premium_product_id' => 'wedding_pro_unlock',
                'premium_activated_at' => now()->toDateTimeString(),
                'apple_original_transaction_id' => 'admin-demo-pro-form',
            ])
            ->call('save')
            ->assertHasNoFormErrors();

        $user->refresh();

        $this->assertTrue($user->isPremium());
        $this->assertSame('wedding_pro_unlock', $user->premium_product_id);
        $this->assertNotNull($user->premium_activated_at);
        $this->assertSame('admin-demo-pro-form', $user->apple_original_transaction_id);
    }

    public function test_super_admin_can_activate_wedding_pro_from_table_action(): void
    {
        $admin = $this->actingAsSuperAdmin();
        $user = User::factory()->create([
            'email' => 'pro-table@example.com',
            'is_premium' => false,
        ]);

        Livewire::actingAs($admin)
            ->test(ListUsers::class)
            ->callTableAction('activateWeddingPro', $user);

        $user->refresh();

        $this->assertTrue($user->isPremium());
        $this->assertSame('wedding_pro_unlock', $user->premium_product_id);
        $this->assertNotNull($user->premium_activated_at);
    }

    public function test_super_admin_can_revoke_wedding_pro_from_table_action(): void
    {
        $admin = $this->actingAsSuperAdmin();
        $user = User::factory()->create([
            'email' => 'revoke-pro@example.com',
            'is_premium' => true,
            'premium_product_id' => 'wedding_pro_unlock',
            'premium_activated_at' => now(),
            'apple_original_transaction_id' => 'admin-demo-revoke',
        ]);

        Livewire::actingAs($admin)
            ->test(ListUsers::class)
            ->callTableAction('revokeWeddingPro', $user);

        $user->refresh();

        $this->assertFalse($user->isPremium());
        $this->assertNull($user->premium_product_id);
        $this->assertNull($user->premium_activated_at);
        $this->assertNull($user->apple_original_transaction_id);
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
            ->assertSee('Pro')
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
