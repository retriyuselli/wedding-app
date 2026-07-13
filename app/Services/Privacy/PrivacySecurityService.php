<?php

namespace App\Services\Privacy;

use App\Models\User;
use App\Support\PrivacySettings;

class PrivacySecurityService
{
    /**
     * @return array{
     *     status: string,
     *     title: string,
     *     message: string,
     *     score: int,
     *     checks: list<array{key: string, passed: bool, label: string, detail: string}>
     * }
     */
    public function summary(User $user): array
    {
        $sessionCount = $user->tokens()->count();
        $trustedCount = $user->trustedDevices()->where('is_trusted', true)->count();
        $passwordAgeDays = $user->password_changed_at
            ? (int) $user->password_changed_at->diffInDays(now())
            : null;

        $checks = [
            [
                'key' => 'password',
                'passed' => $user->usesSocialLogin() || filled($user->password),
                'label' => $user->usesSocialLogin()
                    ? 'Masuk dengan akun sosial'
                    : 'Kata sandi akun aktif',
                'detail' => $user->usesSocialLogin()
                    ? 'Akun dilindungi oleh Google atau Apple.'
                    : ($passwordAgeDays === null
                        ? 'Pastikan kata sandi tetap aman dan unik.'
                        : "Terakhir diubah {$passwordAgeDays} hari yang lalu."),
            ],
            [
                'key' => 'two_factor',
                'passed' => (bool) $user->two_factor_enabled,
                'label' => 'Verifikasi dua langkah',
                'detail' => $user->two_factor_enabled
                    ? 'Kode OTP email aktif untuk login.'
                    : 'Aktifkan 2FA untuk perlindungan ekstra.',
            ],
            [
                'key' => 'trusted_devices',
                'passed' => $trustedCount > 0,
                'label' => 'Perangkat terpercaya',
                'detail' => $trustedCount > 0
                    ? "{$trustedCount} perangkat ditandai tepercaya."
                    : 'Belum ada perangkat terpercaya yang terdaftar.',
            ],
            [
                'key' => 'sessions',
                'passed' => $sessionCount > 0 && $sessionCount <= 5,
                'label' => 'Sesi aktif',
                'detail' => "{$sessionCount} sesi login aktif.",
            ],
        ];

        $passed = collect($checks)->where('passed', true)->count();
        $total = count($checks);
        $score = (int) round(($passed / max($total, 1)) * 100);
        $secure = $score >= 75;

        return [
            'status' => $secure ? 'secure' : 'attention',
            'title' => $secure ? 'Akun Anda aman' : 'Perlu perhatian keamanan',
            'message' => $secure
                ? 'Kami melindungi data Anda dengan standar keamanan tinggi.'
                : 'Lengkapi pengaturan keamanan untuk melindungi akun Anda.',
            'score' => $score,
            'checks' => $checks,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function visibility(User $user): array
    {
        return PrivacySettings::forUser($user);
    }

    /**
     * @param  array<string, mixed>  $input
     * @return array<string, mixed>
     */
    public function updateVisibility(User $user, array $input): array
    {
        $validated = PrivacySettings::validatedPayload($input);
        $merged = array_merge(PrivacySettings::forUser($user), $validated);

        $user->update([
            'privacy_settings' => $merged,
        ]);

        return PrivacySettings::forUser($user->fresh());
    }

    /**
     * @return list<array{key: string, title: string, description: string, category: string}>
     */
    public function appPermissionsCatalog(): array
    {
        return [
            [
                'key' => 'notifications',
                'title' => 'Notifikasi',
                'description' => 'Mengirim pengingat checklist, RSVP, dan update vendor.',
                'category' => 'communication',
            ],
            [
                'key' => 'photos',
                'title' => 'Foto & Media',
                'description' => 'Mengunggah bukti pembayaran, dokumen, dan foto inspirasi.',
                'category' => 'media',
            ],
            [
                'key' => 'camera',
                'title' => 'Kamera',
                'description' => 'Mengambil foto langsung untuk dokumen atau bukti.',
                'category' => 'media',
            ],
            [
                'key' => 'contacts',
                'title' => 'Kontak',
                'description' => 'Menghubungkan data tamu dengan kontak perangkat.',
                'category' => 'contacts',
            ],
        ];
    }
}
