<?php

declare(strict_types=1);

namespace App\Policies;

use App\Models\CustomerNotification;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Foundation\Auth\User as AuthUser;

class CustomerNotificationPolicy
{
    use HandlesAuthorization;

    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:CustomerNotification');
    }

    public function view(AuthUser $authUser, CustomerNotification $customerNotification): bool
    {
        return $authUser->can('View:CustomerNotification');
    }

    public function create(AuthUser $authUser): bool
    {
        return $this->isSuperAdmin($authUser);
    }

    public function update(AuthUser $authUser, CustomerNotification $customerNotification): bool
    {
        return $authUser->can('Update:CustomerNotification');
    }

    public function delete(AuthUser $authUser, CustomerNotification $customerNotification): bool
    {
        return $authUser->can('Delete:CustomerNotification');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:CustomerNotification');
    }

    public function restore(AuthUser $authUser, CustomerNotification $customerNotification): bool
    {
        return $authUser->can('Restore:CustomerNotification');
    }

    public function forceDelete(AuthUser $authUser, CustomerNotification $customerNotification): bool
    {
        return $authUser->can('ForceDelete:CustomerNotification');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:CustomerNotification');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:CustomerNotification');
    }

    public function replicate(AuthUser $authUser, CustomerNotification $customerNotification): bool
    {
        return $this->isSuperAdmin($authUser);
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:CustomerNotification');
    }

    private function isSuperAdmin(AuthUser $authUser): bool
    {
        return $authUser instanceof User && $authUser->isSuperAdmin();
    }
}
