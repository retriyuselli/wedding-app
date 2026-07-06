<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\CustomerPaymentMethod;
use Illuminate\Auth\Access\HandlesAuthorization;

class CustomerPaymentMethodPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:CustomerPaymentMethod');
    }

    public function view(AuthUser $authUser, CustomerPaymentMethod $customerPaymentMethod): bool
    {
        return $authUser->can('View:CustomerPaymentMethod');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:CustomerPaymentMethod');
    }

    public function update(AuthUser $authUser, CustomerPaymentMethod $customerPaymentMethod): bool
    {
        return $authUser->can('Update:CustomerPaymentMethod');
    }

    public function delete(AuthUser $authUser, CustomerPaymentMethod $customerPaymentMethod): bool
    {
        return $authUser->can('Delete:CustomerPaymentMethod');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:CustomerPaymentMethod');
    }

    public function restore(AuthUser $authUser, CustomerPaymentMethod $customerPaymentMethod): bool
    {
        return $authUser->can('Restore:CustomerPaymentMethod');
    }

    public function forceDelete(AuthUser $authUser, CustomerPaymentMethod $customerPaymentMethod): bool
    {
        return $authUser->can('ForceDelete:CustomerPaymentMethod');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:CustomerPaymentMethod');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:CustomerPaymentMethod');
    }

    public function replicate(AuthUser $authUser, CustomerPaymentMethod $customerPaymentMethod): bool
    {
        return $authUser->can('Replicate:CustomerPaymentMethod');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:CustomerPaymentMethod');
    }

}