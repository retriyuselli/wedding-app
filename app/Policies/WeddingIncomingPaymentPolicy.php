<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\WeddingIncomingPayment;
use Illuminate\Auth\Access\HandlesAuthorization;

class WeddingIncomingPaymentPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:WeddingIncomingPayment');
    }

    public function view(AuthUser $authUser, WeddingIncomingPayment $weddingIncomingPayment): bool
    {
        return $authUser->can('View:WeddingIncomingPayment');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:WeddingIncomingPayment');
    }

    public function update(AuthUser $authUser, WeddingIncomingPayment $weddingIncomingPayment): bool
    {
        return $authUser->can('Update:WeddingIncomingPayment');
    }

    public function delete(AuthUser $authUser, WeddingIncomingPayment $weddingIncomingPayment): bool
    {
        return $authUser->can('Delete:WeddingIncomingPayment');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:WeddingIncomingPayment');
    }

    public function restore(AuthUser $authUser, WeddingIncomingPayment $weddingIncomingPayment): bool
    {
        return $authUser->can('Restore:WeddingIncomingPayment');
    }

    public function forceDelete(AuthUser $authUser, WeddingIncomingPayment $weddingIncomingPayment): bool
    {
        return $authUser->can('ForceDelete:WeddingIncomingPayment');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:WeddingIncomingPayment');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:WeddingIncomingPayment');
    }

    public function replicate(AuthUser $authUser, WeddingIncomingPayment $weddingIncomingPayment): bool
    {
        return $authUser->can('Replicate:WeddingIncomingPayment');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:WeddingIncomingPayment');
    }

}