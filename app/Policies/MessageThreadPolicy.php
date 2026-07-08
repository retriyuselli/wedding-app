<?php

declare(strict_types=1);

namespace App\Policies;

use App\Models\MessageThread;
use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Foundation\Auth\User as AuthUser;

class MessageThreadPolicy
{
    use HandlesAuthorization;

    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:MessageThread');
    }

    public function view(AuthUser $authUser, MessageThread $messageThread): bool
    {
        return $authUser->can('View:MessageThread');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:MessageThread');
    }

    public function update(AuthUser $authUser, MessageThread $messageThread): bool
    {
        return $authUser->can('Update:MessageThread');
    }

    public function delete(AuthUser $authUser, MessageThread $messageThread): bool
    {
        return $authUser->can('Delete:MessageThread');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:MessageThread');
    }

    public function restore(AuthUser $authUser, MessageThread $messageThread): bool
    {
        return $authUser->can('Restore:MessageThread');
    }

    public function forceDelete(AuthUser $authUser, MessageThread $messageThread): bool
    {
        return $authUser->can('ForceDelete:MessageThread');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:MessageThread');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:MessageThread');
    }

    public function replicate(AuthUser $authUser, MessageThread $messageThread): bool
    {
        return $authUser->can('Replicate:MessageThread');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:MessageThread');
    }
}
