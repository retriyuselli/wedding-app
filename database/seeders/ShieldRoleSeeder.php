<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class ShieldRoleSeeder extends Seeder
{
    /**
     * @var list<string>
     */
    private const SUPER_ADMIN_EMAILS = [
        'test@example.com',
        'ramadhona.utama@gmail.com',
        'review.pro@weddingapp.co.id',
    ];

    public function run(): void
    {
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        $guard = 'web';
        $superAdmin = Role::findOrCreate(
            config('filament-shield.super_admin.name', 'super_admin'),
            $guard,
        );
        Role::findOrCreate('admin', $guard);
        Role::findOrCreate(config('filament-shield.panel_user.name', 'panel_user'), $guard);
        Role::findOrCreate('vendor', $guard);

        User::query()
            ->whereIn('email', self::SUPER_ADMIN_EMAILS)
            ->each(function (User $user) use ($superAdmin): void {
                if (! $user->hasRole($superAdmin)) {
                    $user->assignRole($superAdmin);
                }
            });
    }
}
