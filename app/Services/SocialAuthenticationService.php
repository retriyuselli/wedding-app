<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SocialAuthenticationService
{
    public function __construct(
        private GoogleTokenVerifier $googleTokenVerifier,
        private AppleTokenVerifier $appleTokenVerifier,
    ) {}

    public function userFromGoogleIdToken(string $idToken): User
    {
        $payload = $this->googleTokenVerifier->verify($idToken);

        $googleId = (string) $payload['sub'];
        $email = (string) $payload['email'];
        $name = (string) ($payload['name'] ?? Str::before($email, '@'));
        $avatarUrl = isset($payload['picture']) ? (string) $payload['picture'] : null;
        $emailVerified = filter_var($payload['email_verified'] ?? false, FILTER_VALIDATE_BOOL);

        $user = User::query()
            ->where('google_id', $googleId)
            ->orWhere('email', $email)
            ->first();

        if ($user) {
            $user->fill([
                'google_id' => $googleId,
                'name' => $name,
            ]);

            if ($avatarUrl && ! $user->avatar_url) {
                $user->avatar_url = $avatarUrl;
            }

            if ($emailVerified && ! $user->email_verified_at) {
                $user->email_verified_at = now();
            }

            $user->save();

            return $user;
        }

        return User::create([
            'name' => $name,
            'email' => $email,
            'google_id' => $googleId,
            'avatar_url' => $avatarUrl,
            'password' => Hash::make(Str::password(32)),
            'email_verified_at' => $emailVerified ? now() : null,
        ]);
    }

    public function userFromAppleIdentityToken(
        string $identityToken,
        ?string $fullName = null,
        ?string $email = null,
    ): User {
        $payload = $this->appleTokenVerifier->verify($identityToken);

        $appleId = (string) $payload['sub'];
        $email ??= isset($payload['email']) ? (string) $payload['email'] : null;
        $name = $fullName ?? ($email ? Str::before($email, '@') : 'Apple User');
        $emailVerified = filter_var($payload['email_verified'] ?? false, FILTER_VALIDATE_BOOL);

        $user = User::query()
            ->where(function ($query) use ($appleId, $email): void {
                $query->where('apple_id', $appleId);

                if ($email) {
                    $query->orWhere('email', $email);
                }
            })
            ->first();

        if ($user) {
            $user->fill([
                'apple_id' => $appleId,
            ]);

            if ($fullName) {
                $user->name = $fullName;
            }

            if ($email && ! $user->email) {
                $user->email = $email;
            }

            if ($emailVerified && ! $user->email_verified_at) {
                $user->email_verified_at = now();
            }

            $user->save();

            return $user;
        }

        return User::create([
            'name' => $name,
            'email' => $email ?? $appleId.'@privaterelay.appleid.com',
            'apple_id' => $appleId,
            'password' => Hash::make(Str::password(32)),
            'email_verified_at' => $emailVerified ? now() : null,
        ]);
    }
}
