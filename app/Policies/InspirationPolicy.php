<?php

declare(strict_types=1);

namespace App\Policies;

use App\Models\Inspiration;
use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Foundation\Auth\User as AuthUser;

class InspirationPolicy
{
    use HandlesAuthorization;

    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:Inspiration');
    }

    public function view(AuthUser $authUser, Inspiration $inspiration): bool
    {
        return $authUser->can('View:Inspiration');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:Inspiration');
    }

    public function update(AuthUser $authUser, Inspiration $inspiration): bool
    {
        return $authUser->can('Update:Inspiration');
    }

    public function delete(AuthUser $authUser, Inspiration $inspiration): bool
    {
        return $authUser->can('Delete:Inspiration');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:Inspiration');
    }

    public function restore(AuthUser $authUser, Inspiration $inspiration): bool
    {
        return $authUser->can('Restore:Inspiration');
    }

    public function forceDelete(AuthUser $authUser, Inspiration $inspiration): bool
    {
        return $authUser->can('ForceDelete:Inspiration');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:Inspiration');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:Inspiration');
    }

    public function replicate(AuthUser $authUser, Inspiration $inspiration): bool
    {
        return $authUser->can('Replicate:Inspiration');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:Inspiration');
    }
}
