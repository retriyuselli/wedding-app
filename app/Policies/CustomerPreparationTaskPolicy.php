<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\CustomerPreparationTask;
use Illuminate\Auth\Access\HandlesAuthorization;

class CustomerPreparationTaskPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:CustomerPreparationTask');
    }

    public function view(AuthUser $authUser, CustomerPreparationTask $customerPreparationTask): bool
    {
        return $authUser->can('View:CustomerPreparationTask');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:CustomerPreparationTask');
    }

    public function update(AuthUser $authUser, CustomerPreparationTask $customerPreparationTask): bool
    {
        return $authUser->can('Update:CustomerPreparationTask');
    }

    public function delete(AuthUser $authUser, CustomerPreparationTask $customerPreparationTask): bool
    {
        return $authUser->can('Delete:CustomerPreparationTask');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:CustomerPreparationTask');
    }

    public function restore(AuthUser $authUser, CustomerPreparationTask $customerPreparationTask): bool
    {
        return $authUser->can('Restore:CustomerPreparationTask');
    }

    public function forceDelete(AuthUser $authUser, CustomerPreparationTask $customerPreparationTask): bool
    {
        return $authUser->can('ForceDelete:CustomerPreparationTask');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:CustomerPreparationTask');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:CustomerPreparationTask');
    }

    public function replicate(AuthUser $authUser, CustomerPreparationTask $customerPreparationTask): bool
    {
        return $authUser->can('Replicate:CustomerPreparationTask');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:CustomerPreparationTask');
    }

}