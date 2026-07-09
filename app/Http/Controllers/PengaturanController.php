<?php

namespace App\Http\Controllers;

use App\Support\HelpContent;
use App\Support\UserSettings;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PengaturanController extends Controller
{
    public function index(Request $request): View
    {
        $user = $request->user();
        $info = $user->weddingInfo;
        $events = $user->weddingEvents()->get();
        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->filter(fn ($event) => $event->tgl_acara?->isFuture())->sortBy('tgl_acara')->first()
            ?? $events->sortByDesc('tgl_acara')->first();

        $tab = $request->string('tab', UserSettings::TabUmum)->toString();

        if (! in_array($tab, UserSettings::tabs(), true)) {
            $tab = UserSettings::TabUmum;
        }

        $settings = UserSettings::forUser($user);

        return view('pengaturan.index', [
            'user' => $user,
            'coupleLabel' => $this->coupleLabel($info, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d F Y'),
            'unreadNotifications' => $user->customerNotifications()->where('is_unread', true)->count(),
            'tab' => $tab,
            'tabLabels' => UserSettings::tabLabels(),
            'settings' => $settings,
            'currencyOptions' => UserSettings::currencyOptions(),
            'dateFormatOptions' => UserSettings::dateFormatOptions(),
            'timezoneOptions' => UserSettings::timezoneOptions(),
            'languageOptions' => UserSettings::languageOptions(),
            'appVersion' => HelpContent::appVersion(),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $tab = $request->string('tab', UserSettings::TabUmum)->toString();

        if (! in_array($tab, UserSettings::tabs(), true)) {
            $tab = UserSettings::TabUmum;
        }

        $rules = match ($tab) {
            UserSettings::TabNotifikasi => [
                'email_notifications' => ['sometimes', 'boolean'],
                'push_notifications' => ['sometimes', 'boolean'],
                'task_reminders' => ['sometimes', 'boolean'],
                'vendor_updates' => ['sometimes', 'boolean'],
                'guest_rsvp_alerts' => ['sometimes', 'boolean'],
                'sound' => ['sometimes', 'boolean'],
                'vibration' => ['sometimes', 'boolean'],
            ],
            UserSettings::TabTampilan => [
                'dark_mode' => ['sometimes', 'boolean'],
                'compact_mode' => ['sometimes', 'boolean'],
                'reduce_animations' => ['sometimes', 'boolean'],
                'show_tips' => ['sometimes', 'boolean'],
            ],
            UserSettings::TabBahasa => [
                'language' => ['required', 'in:'.implode(',', array_keys(UserSettings::languageOptions()))],
                'currency' => ['required', 'in:'.implode(',', array_keys(UserSettings::currencyOptions()))],
                'date_format' => ['required', 'in:'.implode(',', array_keys(UserSettings::dateFormatOptions()))],
                'timezone' => ['required', 'in:'.implode(',', array_keys(UserSettings::timezoneOptions()))],
            ],
            UserSettings::TabSinkronisasi => [
                'auto_sync' => ['sometimes', 'boolean'],
                'sync_on_wifi_only' => ['sometimes', 'boolean'],
                'auto_save' => ['sometimes', 'boolean'],
            ],
            UserSettings::TabLainnya => [
                'analytics_enabled' => ['sometimes', 'boolean'],
            ],
            default => [
                'dark_mode' => ['sometimes', 'boolean'],
                'currency' => ['required', 'in:'.implode(',', array_keys(UserSettings::currencyOptions()))],
                'date_format' => ['required', 'in:'.implode(',', array_keys(UserSettings::dateFormatOptions()))],
                'timezone' => ['required', 'in:'.implode(',', array_keys(UserSettings::timezoneOptions()))],
                'sound' => ['sometimes', 'boolean'],
                'vibration' => ['sometimes', 'boolean'],
                'auto_save' => ['sometimes', 'boolean'],
                'show_tips' => ['sometimes', 'boolean'],
            ],
        };

        $validated = $request->validate($rules);

        $booleanFields = [
            'dark_mode', 'sound', 'vibration', 'auto_save', 'show_tips',
            'email_notifications', 'push_notifications', 'task_reminders',
            'vendor_updates', 'guest_rsvp_alerts', 'compact_mode',
            'reduce_animations', 'auto_sync', 'sync_on_wifi_only', 'analytics_enabled',
        ];

        $payload = [];

        foreach ($validated as $key => $value) {
            if (in_array($key, $booleanFields, true)) {
                $payload[$key] = $request->boolean($key);
            } else {
                $payload[$key] = $value;
            }
        }

        foreach ($booleanFields as $field) {
            if (array_key_exists($field, $rules) && ! array_key_exists($field, $payload)) {
                $payload[$field] = false;
            }
        }

        $user = $request->user();
        $user->update([
            'notification_settings' => array_merge(UserSettings::forUser($user), $payload),
        ]);

        return redirect()
            ->route('pengaturan', ['tab' => $tab])
            ->with('success', 'Pengaturan berhasil disimpan.');
    }

    public function clearCache(Request $request): RedirectResponse
    {
        $tab = $request->string('tab', UserSettings::TabUmum)->toString();

        return redirect()
            ->route('pengaturan', ['tab' => $tab])
            ->with('success', 'Cache aplikasi berhasil dibersihkan.');
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
