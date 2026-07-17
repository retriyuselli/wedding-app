<?php

namespace App\Observers;

use App\Models\User;
use App\Services\DefaultWeddingEventProvisioner;
use App\Services\UserStorageCleanup;

class UserObserver
{
    public function __construct(
        private DefaultWeddingEventProvisioner $weddingEventProvisioner,
        private UserStorageCleanup $userStorageCleanup,
    ) {}

    public function created(User $user): void
    {
        $this->weddingEventProvisioner->provisionFor($user);
    }

    public function deleting(User $user): void
    {
        $this->userStorageCleanup->cleanup($user);
    }
}
