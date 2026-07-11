<?php

namespace App\Providers;

use App\Contracts\PushNotificationDriver;
use App\Models\User;
use App\Models\WeddingEvent;
use App\Observers\UserObserver;
use App\Observers\WeddingEventObserver;
use App\Services\PushNotificationService;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(PushNotificationDriver::class, fn (): PushNotificationDriver => PushNotificationService::resolveDriver());
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        User::observe(UserObserver::class);
        WeddingEvent::observe(WeddingEventObserver::class);
    }
}
