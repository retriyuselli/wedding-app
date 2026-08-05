<?php

namespace App\Services\Privacy;

use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class TwoFactorAuthService
{
    private const CODE_TTL_SECONDS = 600;

    private const PENDING_TTL_SECONDS = 600;

    private const MAX_FAILED_ATTEMPTS = 5;

    private const LOCKOUT_SECONDS = 900;

    public function isEnabled(User $user): bool
    {
        return (bool) $user->two_factor_enabled;
    }

    public function sendEnableCode(User $user): void
    {
        $this->storeAndSendCode($user, 'enable');
    }

    public function confirmEnable(User $user, string $code): void
    {
        $this->assertValidCode($user, 'enable', $code);

        $user->forceFill([
            'two_factor_enabled' => true,
        ])->save();

        $this->forgetCode($user, 'enable');
    }

    public function sendDisableCode(User $user): void
    {
        if (! $this->isEnabled($user)) {
            throw ValidationException::withMessages([
                'code' => ['Verifikasi dua langkah belum aktif.'],
            ]);
        }

        $this->storeAndSendCode($user, 'disable');
    }

    public function confirmDisable(User $user, string $code, ?string $password = null): void
    {
        if (! $user->usesSocialLogin()) {
            if (! is_string($password) || $password === '' || ! Hash::check($password, $user->password)) {
                throw ValidationException::withMessages([
                    'password' => ['Kata sandi tidak sesuai.'],
                ]);
            }
        }

        $this->assertValidCode($user, 'disable', $code);

        $user->forceFill([
            'two_factor_enabled' => false,
        ])->save();

        $this->forgetCode($user, 'disable');
    }

    /**
     * @return array{requires_two_factor: true, two_factor_token: string, message: string}
     */
    public function beginLoginChallenge(User $user): array
    {
        $token = Str::random(64);

        Cache::put($this->pendingKey($token), [
            'user_id' => $user->id,
        ], self::PENDING_TTL_SECONDS);

        $this->storeAndSendCode($user, 'login');

        return [
            'requires_two_factor' => true,
            'two_factor_token' => $token,
            'message' => 'Kode verifikasi telah dikirim ke email Anda.',
        ];
    }

    public function completeLoginChallenge(string $twoFactorToken, string $code): User
    {
        $pending = Cache::get($this->pendingKey($twoFactorToken));

        if (! is_array($pending) || ! isset($pending['user_id'])) {
            throw ValidationException::withMessages([
                'two_factor_token' => ['Sesi verifikasi tidak valid atau sudah kedaluwarsa.'],
            ]);
        }

        $user = User::query()->findOrFail($pending['user_id']);

        if (! $this->isEnabled($user)) {
            throw ValidationException::withMessages([
                'code' => ['Verifikasi dua langkah tidak aktif untuk akun ini.'],
            ]);
        }

        $this->assertValidCode($user, 'login', $code);
        $this->forgetCode($user, 'login');
        Cache::forget($this->pendingKey($twoFactorToken));

        return $user;
    }

    private function storeAndSendCode(User $user, string $purpose): void
    {
        $code = (string) random_int(100000, 999999);

        Cache::put($this->codeKey($user, $purpose), Hash::make($code), self::CODE_TTL_SECONDS);

        if (app()->environment('testing')) {
            Cache::put($this->codeKey($user, $purpose).':plain', $code, self::CODE_TTL_SECONDS);
        }

        $subject = match ($purpose) {
            'enable' => 'Kode Verifikasi Dua Langkah',
            'disable' => 'Kode Nonaktifkan Verifikasi Dua Langkah',
            'login' => 'Kode Login Verifikasi Dua Langkah',
            default => 'Kode Verifikasi Dua Langkah',
        };

        Mail::raw(
            "Kode verifikasi Wedding App Anda: {$code}\nBerlaku 10 menit.",
            function ($message) use ($user, $subject): void {
                $message->from(
                    (string) config('mail.from.address'),
                    (string) config('mail.from.name', 'Wedding App'),
                )
                    ->to($user->email)
                    ->subject($subject);
            }
        );
    }

    private function assertValidCode(User $user, string $purpose, string $code): void
    {
        if (Cache::has($this->lockoutKey($user, $purpose))) {
            throw ValidationException::withMessages([
                'code' => ['Terlalu banyak percobaan gagal. Coba lagi dalam 15 menit.'],
            ]);
        }

        $hashed = Cache::get($this->codeKey($user, $purpose));

        if (! is_string($hashed) || ! Hash::check($code, $hashed)) {
            $attempts = (int) Cache::get($this->attemptKey($user, $purpose), 0) + 1;
            Cache::put($this->attemptKey($user, $purpose), $attempts, self::CODE_TTL_SECONDS);

            if ($attempts >= self::MAX_FAILED_ATTEMPTS) {
                Cache::put($this->lockoutKey($user, $purpose), true, self::LOCKOUT_SECONDS);
                Cache::forget($this->attemptKey($user, $purpose));

                throw ValidationException::withMessages([
                    'code' => ['Terlalu banyak percobaan gagal. Coba lagi dalam 15 menit.'],
                ]);
            }

            throw ValidationException::withMessages([
                'code' => ['Kode verifikasi tidak valid atau sudah kedaluwarsa.'],
            ]);
        }

        Cache::forget($this->attemptKey($user, $purpose));
    }

    private function forgetCode(User $user, string $purpose): void
    {
        Cache::forget($this->codeKey($user, $purpose));
    }

    private function codeKey(User $user, string $purpose): string
    {
        return "two_factor:{$purpose}:{$user->id}";
    }

    private function pendingKey(string $token): string
    {
        return "two_factor:pending:{$token}";
    }

    private function attemptKey(User $user, string $purpose): string
    {
        return "two_factor:attempts:{$purpose}:{$user->id}";
    }

    private function lockoutKey(User $user, string $purpose): string
    {
        return "two_factor:lockout:{$purpose}:{$user->id}";
    }
}
