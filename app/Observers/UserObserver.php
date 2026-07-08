<?php

namespace App\Observers;

use App\Models\User;
use App\Services\DefaultWeddingEventProvisioner;

class UserObserver
{
    public function __construct(
        private DefaultWeddingEventProvisioner $weddingEventProvisioner,
    ) {}

    public function created(User $user): void
    {
        $this->weddingEventProvisioner->provisionFor($user);
    }
}
