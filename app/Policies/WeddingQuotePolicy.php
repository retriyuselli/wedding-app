<?php

declare(strict_types=1);

namespace App\Policies;

use Illuminate\Foundation\Auth\User as AuthUser;
use App\Models\WeddingQuote;
use Illuminate\Auth\Access\HandlesAuthorization;

class WeddingQuotePolicy
{
    use HandlesAuthorization;
    
    public function viewAny(AuthUser $authUser): bool
    {
        return $authUser->can('ViewAny:WeddingQuote');
    }

    public function view(AuthUser $authUser, WeddingQuote $weddingQuote): bool
    {
        return $authUser->can('View:WeddingQuote');
    }

    public function create(AuthUser $authUser): bool
    {
        return $authUser->can('Create:WeddingQuote');
    }

    public function update(AuthUser $authUser, WeddingQuote $weddingQuote): bool
    {
        return $authUser->can('Update:WeddingQuote');
    }

    public function delete(AuthUser $authUser, WeddingQuote $weddingQuote): bool
    {
        return $authUser->can('Delete:WeddingQuote');
    }

    public function deleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('DeleteAny:WeddingQuote');
    }

    public function restore(AuthUser $authUser, WeddingQuote $weddingQuote): bool
    {
        return $authUser->can('Restore:WeddingQuote');
    }

    public function forceDelete(AuthUser $authUser, WeddingQuote $weddingQuote): bool
    {
        return $authUser->can('ForceDelete:WeddingQuote');
    }

    public function forceDeleteAny(AuthUser $authUser): bool
    {
        return $authUser->can('ForceDeleteAny:WeddingQuote');
    }

    public function restoreAny(AuthUser $authUser): bool
    {
        return $authUser->can('RestoreAny:WeddingQuote');
    }

    public function replicate(AuthUser $authUser, WeddingQuote $weddingQuote): bool
    {
        return $authUser->can('Replicate:WeddingQuote');
    }

    public function reorder(AuthUser $authUser): bool
    {
        return $authUser->can('Reorder:WeddingQuote');
    }

}