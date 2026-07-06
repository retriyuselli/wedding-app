<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\CustomerPreparationSection;
use Illuminate\Auth\Access\HandlesAuthorization;

class CustomerPreparationSectionPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:CustomerPreparationSection');
    }

    public function view(AuthUser $authUser, CustomerPreparationSection $customerPreparationSection): bool
    {
        return $authUser->can('View:CustomerPreparationSection');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:CustomerPreparationSection');
    }

    public function update(AuthUser $authUser, CustomerPreparationSection $customerPreparationSection): bool
    {
        return $authUser->can('Update:CustomerPreparationSection');
    }

    public function delete(AuthUser $authUser, CustomerPreparationSection $customerPreparationSection): bool
    {
        return $authUser->can('Delete:CustomerPreparationSection');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:CustomerPreparationSection');
    }

    public function restore(AuthUser $authUser, CustomerPreparationSection $customerPreparationSection): bool
    {
        return $authUser->can('Restore:CustomerPreparationSection');
    }

    public function forceDelete(AuthUser $authUser, CustomerPreparationSection $customerPreparationSection): bool
    {
        return $authUser->can('ForceDelete:CustomerPreparationSection');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:CustomerPreparationSection');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:CustomerPreparationSection');
    }

    public function replicate(AuthUser $authUser, CustomerPreparationSection $customerPreparationSection): bool
    {
        return $authUser->can('Replicate:CustomerPreparationSection');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:CustomerPreparationSection');
    }

}