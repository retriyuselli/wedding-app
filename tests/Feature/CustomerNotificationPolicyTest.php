<?php

namespace Tests\Feature;

use App\Models\CustomerNotification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class CustomerNotificationPolicyTest extends TestCase
{
    use RefreshDatabase;

    public function test_super_admin_can_create_customer_notifications(): void
    {
        $this->createRole(config('filament-shield.super_admin.name', 'super_admin'));

        $user = User::factory()->create();
        $user->assignRole(config('filament-shield.super_admin.name', 'super_admin'));

        $this->assertTrue($user->can('create', CustomerNotification::class));
    }

    public function test_non_super_admin_cannot_create_customer_notifications_even_with_create_permission(): void
    {
        $role = $this->createRole('panel_user');
        $permission = Permission::findOrCreate('Create:CustomerNotification', 'web');
        $role->givePermissionTo($permission);

        $user = User::factory()->create();
        $user->assignRole($role);

        $this->assertTrue($user->can('Create:CustomerNotification'));
        $this->assertFalse($user->can('create', CustomerNotification::class));
    }

    public function test_regular_user_cannot_create_customer_notifications(): void
    {
        $user = User::factory()->create();

        $this->assertFalse($user->can('create', CustomerNotification::class));
    }

    public function test_only_super_admin_can_replicate_customer_notifications(): void
    {
        $this->createRole(config('filament-shield.super_admin.name', 'super_admin'));

        $superAdmin = User::factory()->create();
        $superAdmin->assignRole(config('filament-shield.super_admin.name', 'super_admin'));

        $otherUser = User::factory()->create();
        $notification = CustomerNotification::factory()->create();

        $this->assertTrue($superAdmin->can('replicate', $notification));
        $this->assertFalse($otherUser->can('replicate', $notification));
    }

    private function createRole(string $name): Role
    {
        return Role::create([
            'name' => $name,
            'guard_name' => 'web',
        ]);
    }
}
