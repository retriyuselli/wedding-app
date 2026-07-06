<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\FamilyMember;
use Illuminate\Auth\Access\HandlesAuthorization;

class FamilyMemberPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:FamilyMember');
    }

    public function view(AuthUser $authUser, FamilyMember $familyMember): bool
    {
        return $authUser->can('View:FamilyMember');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:FamilyMember');
    }

    public function update(AuthUser $authUser, FamilyMember $familyMember): bool
    {
        return $authUser->can('Update:FamilyMember');
    }

    public function delete(AuthUser $authUser, FamilyMember $familyMember): bool
    {
        return $authUser->can('Delete:FamilyMember');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:FamilyMember');
    }

    public function restore(AuthUser $authUser, FamilyMember $familyMember): bool
    {
        return $authUser->can('Restore:FamilyMember');
    }

    public function forceDelete(AuthUser $authUser, FamilyMember $familyMember): bool
    {
        return $authUser->can('ForceDelete:FamilyMember');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:FamilyMember');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:FamilyMember');
    }

    public function replicate(AuthUser $authUser, FamilyMember $familyMember): bool
    {
        return $authUser->can('Replicate:FamilyMember');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:FamilyMember');
    }

}