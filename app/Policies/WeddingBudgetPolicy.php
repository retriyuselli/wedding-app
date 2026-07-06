<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\WeddingBudget;
use Illuminate\Auth\Access\HandlesAuthorization;

class WeddingBudgetPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:WeddingBudget');
    }

    public function view(AuthUser $authUser, WeddingBudget $weddingBudget): bool
    {
        return $authUser->can('View:WeddingBudget');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:WeddingBudget');
    }

    public function update(AuthUser $authUser, WeddingBudget $weddingBudget): bool
    {
        return $authUser->can('Update:WeddingBudget');
    }

    public function delete(AuthUser $authUser, WeddingBudget $weddingBudget): bool
    {
        return $authUser->can('Delete:WeddingBudget');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:WeddingBudget');
    }

    public function restore(AuthUser $authUser, WeddingBudget $weddingBudget): bool
    {
        return $authUser->can('Restore:WeddingBudget');
    }

    public function forceDelete(AuthUser $authUser, WeddingBudget $weddingBudget): bool
    {
        return $authUser->can('ForceDelete:WeddingBudget');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:WeddingBudget');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:WeddingBudget');
    }

    public function replicate(AuthUser $authUser, WeddingBudget $weddingBudget): bool
    {
        return $authUser->can('Replicate:WeddingBudget');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:WeddingBudget');
    }

}