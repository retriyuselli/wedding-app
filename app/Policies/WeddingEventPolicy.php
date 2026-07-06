<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\WeddingEvent;
use Illuminate\Auth\Access\HandlesAuthorization;

class WeddingEventPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:WeddingEvent');
    }

    public function view(AuthUser $authUser, WeddingEvent $weddingEvent): bool
    {
        return $authUser->can('View:WeddingEvent');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:WeddingEvent');
    }

    public function update(AuthUser $authUser, WeddingEvent $weddingEvent): bool
    {
        return $authUser->can('Update:WeddingEvent');
    }

    public function delete(AuthUser $authUser, WeddingEvent $weddingEvent): bool
    {
        return $authUser->can('Delete:WeddingEvent');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:WeddingEvent');
    }

    public function restore(AuthUser $authUser, WeddingEvent $weddingEvent): bool
    {
        return $authUser->can('Restore:WeddingEvent');
    }

    public function forceDelete(AuthUser $authUser, WeddingEvent $weddingEvent): bool
    {
        return $authUser->can('ForceDelete:WeddingEvent');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:WeddingEvent');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:WeddingEvent');
    }

    public function replicate(AuthUser $authUser, WeddingEvent $weddingEvent): bool
    {
        return $authUser->can('Replicate:WeddingEvent');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:WeddingEvent');
    }

}