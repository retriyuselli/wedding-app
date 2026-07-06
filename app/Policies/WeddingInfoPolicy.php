<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\WeddingInfo;
use Illuminate\Auth\Access\HandlesAuthorization;

class WeddingInfoPolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:WeddingInfo');
    }

    public function view(AuthUser $authUser, WeddingInfo $weddingInfo): bool
    {
        return $authUser->can('View:WeddingInfo');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:WeddingInfo');
    }

    public function update(AuthUser $authUser, WeddingInfo $weddingInfo): bool
    {
        return $authUser->can('Update:WeddingInfo');
    }

    public function delete(AuthUser $authUser, WeddingInfo $weddingInfo): bool
    {
        return $authUser->can('Delete:WeddingInfo');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:WeddingInfo');
    }

    public function restore(AuthUser $authUser, WeddingInfo $weddingInfo): bool
    {
        return $authUser->can('Restore:WeddingInfo');
    }

    public function forceDelete(AuthUser $authUser, WeddingInfo $weddingInfo): bool
    {
        return $authUser->can('ForceDelete:WeddingInfo');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:WeddingInfo');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:WeddingInfo');
    }

    public function replicate(AuthUser $authUser, WeddingInfo $weddingInfo): bool
    {
        return $authUser->can('Replicate:WeddingInfo');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:WeddingInfo');
    }

}