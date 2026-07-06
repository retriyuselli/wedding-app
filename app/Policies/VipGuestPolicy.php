<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\VipGuest;
use Illuminate\Auth\Access\HandlesAuthorization;

class VipGuestPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:VipGuest');
    }

    public function view(AuthUser $authUser, VipGuest $vipGuest): bool
    {
        return $authUser->can('View:VipGuest');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:VipGuest');
    }

    public function update(AuthUser $authUser, VipGuest $vipGuest): bool
    {
        return $authUser->can('Update:VipGuest');
    }

    public function delete(AuthUser $authUser, VipGuest $vipGuest): bool
    {
        return $authUser->can('Delete:VipGuest');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:VipGuest');
    }

    public function restore(AuthUser $authUser, VipGuest $vipGuest): bool
    {
        return $authUser->can('Restore:VipGuest');
    }

    public function forceDelete(AuthUser $authUser, VipGuest $vipGuest): bool
    {
        return $authUser->can('ForceDelete:VipGuest');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:VipGuest');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:VipGuest');
    }

    public function replicate(AuthUser $authUser, VipGuest $vipGuest): bool
    {
        return $authUser->can('Replicate:VipGuest');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:VipGuest');
    }

}