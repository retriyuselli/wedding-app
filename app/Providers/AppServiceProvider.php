<?php

namespace App\Providers;

use App\Contracts\PushNotificationDriver;
use App\Models\User;
use App\Models\WeddingEvent;
use App\Observers\UserObserver;
use App\Observers\WeddingEventObserver;
use App\Services\PushNotificationService;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
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

        $this->configureRateLimiting();
    }

    protected function configureRateLimiting(): void
    {
        RateLimiter::for('api', function (Request $request): Limit {
            return Limit::perMinute(120)->by($request->user()?->id ?: $request->ip());
        });

        RateLimiter::for('auth', function (Request $request): Limit {
            return Limit::perMinute(10)->by($request->ip());
        });

        RateLimiter::for('two-factor', function (Request $request): Limit {
            $token = (string) $request->input('two_factor_token', '');

            return Limit::perMinute(10)->by($request->ip().'|'.$token);
        });

        RateLimiter::for('billing-verify', function (Request $request): Limit {
            return Limit::perMinute(15)->by($request->user()?->id ?: $request->ip());
        });
    }
}
