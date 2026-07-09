<?php

namespace App\Support;

use App\Models\User;

class UserSettings
{
    public const TabUmum = 'umum';

    public const TabNotifikasi = 'notifikasi';

    public const TabTampilan = 'tampilan';

    public const TabBahasa = 'bahasa';

    public const TabSinkronisasi = 'sinkronisasi';

    public const TabLainnya = 'lainnya';

    /**
     * @return array<int, string>
     */
    public static function tabs(): array
    {
        return [
            self::TabUmum,
            self::TabNotifikasi,
            self::TabTampilan,
            self::TabBahasa,
            self::TabSinkronisasi,
            self::TabLainnya,
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function tabLabels(): array
    {
        return [
            self::TabUmum => 'Umum',
            self::TabNotifikasi => 'Notifikasi',
            self::TabTampilan => 'Tampilan',
            self::TabBahasa => 'Bahasa & Wilayah',
            self::TabSinkronisasi => 'Sinkronisasi',
            self::TabLainnya => 'Lainnya',
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function defaults(): array
    {
        return [
            'dark_mode' => false,
            'currency' => 'IDR',
            'date_format' => 'd M Y',
            'timezone' => 'Asia/Jakarta',
            'sound' => true,
            'vibration' => true,
            'auto_save' => true,
            'show_tips' => false,
            'language' => 'id',
            'email_notifications' => true,
            'push_notifications' => true,
            'task_reminders' => true,
            'vendor_updates' => true,
            'guest_rsvp_alerts' => true,
            'compact_mode' => false,
            'reduce_animations' => false,
            'auto_sync' => true,
            'sync_on_wifi_only' => false,
            'analytics_enabled' => true,
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function currencyOptions(): array
    {
        return [
            'IDR' => 'IDR (Rp)',
            'USD' => 'USD ($)',
            'SGD' => 'SGD (S$)',
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function dateFormatOptions(): array
    {
        return [
            'd M Y' => 'DD MMM YYYY',
            'd/m/Y' => 'DD/MM/YYYY',
            'Y-m-d' => 'YYYY-MM-DD',
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function timezoneOptions(): array
    {
        return [
            'Asia/Jakarta' => '(GMT+7) Jakarta',
            'Asia/Makassar' => '(GMT+8) Makassar',
            'Asia/Jayapura' => '(GMT+9) Jayapura',
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function languageOptions(): array
    {
        return [
            'id' => 'Indonesia',
            'en' => 'English',
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function forUser(User $user): array
    {
        $stored = is_array($user->notification_settings) ? $user->notification_settings : [];

        return array_merge(self::defaults(), $stored);
    }

    public static function languageLabel(string $code): string
    {
        return self::languageOptions()[$code] ?? 'Indonesia';
    }

    public static function currencyLabel(string $code): string
    {
        return self::currencyOptions()[$code] ?? 'IDR (Rp)';
    }

    public static function timezoneLabel(string $code): string
    {
        return self::timezoneOptions()[$code] ?? '(GMT+7) Jakarta';
    }

    public static function boolLabel(bool $value): string
    {
        return $value ? 'Aktif' : 'Nonaktif';
    }
}
