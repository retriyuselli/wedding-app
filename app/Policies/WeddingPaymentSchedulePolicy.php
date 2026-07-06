<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Auth\Access\HandlesAuthorization;

class WeddingPaymentSchedulePolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:WeddingPaymentSchedule');
    }

    public function view(AuthUser $authUser, WeddingPaymentSchedule $weddingPaymentSchedule): bool
    {
        return $authUser->can('View:WeddingPaymentSchedule');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:WeddingPaymentSchedule');
    }

    public function update(AuthUser $authUser, WeddingPaymentSchedule $weddingPaymentSchedule): bool
    {
        return $authUser->can('Update:WeddingPaymentSchedule');
    }

    public function delete(AuthUser $authUser, WeddingPaymentSchedule $weddingPaymentSchedule): bool
    {
        return $authUser->can('Delete:WeddingPaymentSchedule');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:WeddingPaymentSchedule');
    }

    public function restore(AuthUser $authUser, WeddingPaymentSchedule $weddingPaymentSchedule): bool
    {
        return $authUser->can('Restore:WeddingPaymentSchedule');
    }

    public function forceDelete(AuthUser $authUser, WeddingPaymentSchedule $weddingPaymentSchedule): bool
    {
        return $authUser->can('ForceDelete:WeddingPaymentSchedule');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:WeddingPaymentSchedule');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:WeddingPaymentSchedule');
    }

    public function replicate(AuthUser $authUser, WeddingPaymentSchedule $weddingPaymentSchedule): bool
    {
        return $authUser->can('Replicate:WeddingPaymentSchedule');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:WeddingPaymentSchedule');
    }

}