<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsPremium
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->isPremium()) {
            return response()->json([
                'message' => config('billing.pro_required_message'),
                'code' => 'premium_required',
            ], 403);
        }

        return $next($request);
    }
}
