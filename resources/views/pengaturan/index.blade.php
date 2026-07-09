@extends('layouts.app')

@section('content')
@php
    use App\Support\UserSettings;

    $tabUrl = fn (string $name): string => route('pengaturan', ['tab' => $name]);
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Pengaturan (Settings)</h1>
                <p class="mt-1 text-sm text-gray-500">Kelola preferensi aplikasi dan pengaturan akun Anda.</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <label class="relative hidden sm:block">
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" placeholder="Cari di Wedding App..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[280px]">
                    <span class="pointer-events-none absolute right-3 top-1/2 hidden -translate-y-1/2 rounded-md border border-gray-200 bg-gray-50 px-1.5 py-0.5 text-[10px] font-medium text-gray-400 lg:inline">⌘K</span>
                </label>

                <button type="button" class="relative hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
                    </svg>
                    @if($unreadNotifications > 0)
                        <span class="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-semibold text-white">{{ min($unreadNotifications, 9) }}</span>
                    @endif
                </button>

                <button type="button" class="hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
                    </svg>
                </button>

                <button type="button" class="hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                    </svg>
                </button>

                <a href="{{ route('profil') }}" class="flex items-center gap-2 rounded-xl border border-gray-200 bg-white py-1.5 pl-1.5 pr-3">
                    <x-dummy-image type="avatar" :alt="$coupleLabel" class="h-9 w-9 rounded-full object-cover" />
                    <div class="hidden min-w-0 sm:block">
                        <p class="max-w-[120px] truncate text-sm font-medium text-wedding-ink">{{ $coupleLabel }}</p>
                        @if($weddingDateLabel)
                            <p class="text-[11px] text-gray-400">{{ $weddingDateLabel }}</p>
                        @endif
                    </div>
                </a>
            </div>
        </div>

        @if(session('success'))
            <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2.5 text-sm text-emerald-600">
                <svg class="h-4 w-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
                {{ session('success') }}
            </div>
        @endif

        {{-- Tabs --}}
        <div class="overflow-x-auto border-b border-gray-200">
            <nav class="flex min-w-max gap-6">
                @foreach($tabLabels as $tabKey => $tabLabel)
                    <a href="{{ $tabUrl($tabKey) }}"
                       @class([
                           'border-b-2 pb-3 text-sm font-medium transition-colors',
                           'border-sage-600 text-sage-700' => $tab === $tabKey,
                           'border-transparent text-gray-500 hover:text-gray-800' => $tab !== $tabKey,
                       ])>
                        {{ $tabLabel }}
                    </a>
                @endforeach
            </nav>
        </div>

        <div class="grid gap-5 lg:grid-cols-12 lg:gap-6">
            <div class="space-y-5 lg:col-span-8 lg:space-y-6">
                <form method="POST" action="{{ route('pengaturan.update') }}" class="space-y-5 lg:space-y-6">
                    @csrf
                    @method('PUT')
                    <input type="hidden" name="tab" value="{{ $tab }}">

                    @if($tab === UserSettings::TabUmum)
                        <div class="dashboard-card overflow-hidden">
                            <div class="border-b border-gray-100 px-5 py-4">
                                <h2 class="text-[15px] font-semibold text-wedding-ink">Umum</h2>
                            </div>
                            <div class="divide-y divide-gray-100">
                                <div class="flex items-center justify-between gap-4 px-5 py-4">
                                    <div>
                                        <p class="text-sm font-medium text-wedding-ink">Informasi Aplikasi</p>
                                        <p class="mt-0.5 text-xs text-gray-500">Versi {{ $appVersion }}</p>
                                    </div>
                                    <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                                    </svg>
                                </div>
                                @include('pengaturan.partials.toggle-row', ['name' => 'dark_mode', 'label' => 'Mode Gelap', 'checked' => $settings['dark_mode']])
                                <x-pengaturan.select-row label="Mata Uang">
                                    <select name="currency" class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 text-sm text-gray-700 outline-none ring-sage-300 focus:ring-2">
                                        @foreach($currencyOptions as $value => $label)
                                            <option value="{{ $value }}" @selected($settings['currency'] === $value)>{{ $label }}</option>
                                        @endforeach
                                    </select>
                                </x-pengaturan.select-row>
                                <x-pengaturan.select-row label="Format Tanggal">
                                    <select name="date_format" class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 text-sm text-gray-700 outline-none ring-sage-300 focus:ring-2">
                                        @foreach($dateFormatOptions as $value => $label)
                                            <option value="{{ $value }}" @selected($settings['date_format'] === $value)>{{ $label }}</option>
                                        @endforeach
                                    </select>
                                </x-pengaturan.select-row>
                                <x-pengaturan.select-row label="Zona Waktu">
                                    <select name="timezone" class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 text-sm text-gray-700 outline-none ring-sage-300 focus:ring-2">
                                        @foreach($timezoneOptions as $value => $label)
                                            <option value="{{ $value }}" @selected($settings['timezone'] === $value)>{{ $label }}</option>
                                        @endforeach
                                    </select>
                                </x-pengaturan.select-row>
                            </div>
                        </div>

                        <div class="dashboard-card overflow-hidden">
                            <div class="border-b border-gray-100 px-5 py-4">
                                <h2 class="text-[15px] font-semibold text-wedding-ink">Preferensi</h2>
                            </div>
                            <div class="divide-y divide-gray-100">
                                @include('pengaturan.partials.toggle-row', ['name' => 'sound', 'label' => 'Bunyi', 'checked' => $settings['sound']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'vibration', 'label' => 'Getaran', 'checked' => $settings['vibration']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'auto_save', 'label' => 'Simpan Otomatis', 'checked' => $settings['auto_save']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'show_tips', 'label' => 'Tampilkan Tips', 'checked' => $settings['show_tips']])
                            </div>
                        </div>
                    @elseif($tab === UserSettings::TabNotifikasi)
                        <div class="dashboard-card overflow-hidden">
                            <div class="border-b border-gray-100 px-5 py-4">
                                <h2 class="text-[15px] font-semibold text-wedding-ink">Notifikasi</h2>
                                <p class="mt-0.5 text-xs text-gray-500">Atur cara Anda menerima pemberitahuan</p>
                            </div>
                            <div class="divide-y divide-gray-100">
                                @include('pengaturan.partials.toggle-row', ['name' => 'push_notifications', 'label' => 'Notifikasi Push', 'description' => 'Terima notifikasi di perangkat Anda', 'checked' => $settings['push_notifications']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'email_notifications', 'label' => 'Notifikasi Email', 'description' => 'Kirim ringkasan ke email akun', 'checked' => $settings['email_notifications']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'task_reminders', 'label' => 'Pengingat Tugas', 'description' => 'Ingatkan tugas checklist yang mendekati', 'checked' => $settings['task_reminders']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'vendor_updates', 'label' => 'Update Vendor', 'description' => 'Pesan dan aktivitas vendor terbaru', 'checked' => $settings['vendor_updates']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'guest_rsvp_alerts', 'label' => 'Konfirmasi Tamu', 'description' => 'Notifikasi saat tamu mengonfirmasi kehadiran', 'checked' => $settings['guest_rsvp_alerts']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'sound', 'label' => 'Bunyi Notifikasi', 'checked' => $settings['sound']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'vibration', 'label' => 'Getaran Notifikasi', 'checked' => $settings['vibration']])
                            </div>
                        </div>
                    @elseif($tab === UserSettings::TabTampilan)
                        <div class="dashboard-card overflow-hidden">
                            <div class="border-b border-gray-100 px-5 py-4">
                                <h2 class="text-[15px] font-semibold text-wedding-ink">Tampilan</h2>
                            </div>
                            <div class="divide-y divide-gray-100">
                                @include('pengaturan.partials.toggle-row', ['name' => 'dark_mode', 'label' => 'Mode Gelap', 'description' => 'Gunakan tema gelap di seluruh aplikasi', 'checked' => $settings['dark_mode']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'compact_mode', 'label' => 'Mode Ringkas', 'description' => 'Tampilkan lebih banyak konten di layar', 'checked' => $settings['compact_mode']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'reduce_animations', 'label' => 'Kurangi Animasi', 'checked' => $settings['reduce_animations']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'show_tips', 'label' => 'Tampilkan Tips', 'checked' => $settings['show_tips']])
                            </div>
                        </div>
                    @elseif($tab === UserSettings::TabBahasa)
                        <div class="dashboard-card overflow-hidden">
                            <div class="border-b border-gray-100 px-5 py-4">
                                <h2 class="text-[15px] font-semibold text-wedding-ink">Bahasa & Wilayah</h2>
                            </div>
                            <div class="divide-y divide-gray-100">
                                <x-pengaturan.select-row label="Bahasa" description="Bahasa tampilan aplikasi">
                                    <select name="language" class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 text-sm text-gray-700 outline-none ring-sage-300 focus:ring-2">
                                        @foreach($languageOptions as $value => $label)
                                            <option value="{{ $value }}" @selected($settings['language'] === $value)>{{ $label }}</option>
                                        @endforeach
                                    </select>
                                </x-pengaturan.select-row>
                                <x-pengaturan.select-row label="Mata Uang">
                                    <select name="currency" class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 text-sm text-gray-700 outline-none ring-sage-300 focus:ring-2">
                                        @foreach($currencyOptions as $value => $label)
                                            <option value="{{ $value }}" @selected($settings['currency'] === $value)>{{ $label }}</option>
                                        @endforeach
                                    </select>
                                </x-pengaturan.select-row>
                                <x-pengaturan.select-row label="Format Tanggal">
                                    <select name="date_format" class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 text-sm text-gray-700 outline-none ring-sage-300 focus:ring-2">
                                        @foreach($dateFormatOptions as $value => $label)
                                            <option value="{{ $value }}" @selected($settings['date_format'] === $value)>{{ $label }}</option>
                                        @endforeach
                                    </select>
                                </x-pengaturan.select-row>
                                <x-pengaturan.select-row label="Zona Waktu">
                                    <select name="timezone" class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 text-sm text-gray-700 outline-none ring-sage-300 focus:ring-2">
                                        @foreach($timezoneOptions as $value => $label)
                                            <option value="{{ $value }}" @selected($settings['timezone'] === $value)>{{ $label }}</option>
                                        @endforeach
                                    </select>
                                </x-pengaturan.select-row>
                            </div>
                        </div>
                    @elseif($tab === UserSettings::TabSinkronisasi)
                        <div class="dashboard-card overflow-hidden">
                            <div class="border-b border-gray-100 px-5 py-4">
                                <h2 class="text-[15px] font-semibold text-wedding-ink">Sinkronisasi</h2>
                            </div>
                            <div class="divide-y divide-gray-100">
                                @include('pengaturan.partials.toggle-row', ['name' => 'auto_sync', 'label' => 'Sinkronisasi Otomatis', 'description' => 'Sinkronkan data antar perangkat', 'checked' => $settings['auto_sync']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'sync_on_wifi_only', 'label' => 'Hanya lewat Wi-Fi', 'description' => 'Hemat kuota data seluler', 'checked' => $settings['sync_on_wifi_only']])
                                @include('pengaturan.partials.toggle-row', ['name' => 'auto_save', 'label' => 'Simpan Otomatis', 'checked' => $settings['auto_save']])
                            </div>
                        </div>
                    @else
                        <div class="dashboard-card overflow-hidden">
                            <div class="border-b border-gray-100 px-5 py-4">
                                <h2 class="text-[15px] font-semibold text-wedding-ink">Lainnya</h2>
                            </div>
                            <div class="divide-y divide-gray-100">
                                @include('pengaturan.partials.toggle-row', ['name' => 'analytics_enabled', 'label' => 'Analitik Anonim', 'description' => 'Bantu kami meningkatkan aplikasi', 'checked' => $settings['analytics_enabled']])
                                <a href="{{ route('privacy-policy') }}" target="_blank" rel="noopener" class="flex items-center justify-between gap-4 px-5 py-4 hover:bg-gray-50/60">
                                    <p class="text-sm font-medium text-wedding-ink">Kebijakan Privasi</p>
                                    <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                                    </svg>
                                </a>
                                <a href="{{ route('terms') }}" target="_blank" rel="noopener" class="flex items-center justify-between gap-4 px-5 py-4 hover:bg-gray-50/60">
                                    <p class="text-sm font-medium text-wedding-ink">Syarat & Ketentuan</p>
                                    <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                                    </svg>
                                </a>
                            </div>
                        </div>
                    @endif

                    <div class="flex justify-end">
                        <button type="submit" class="inline-flex h-11 items-center justify-center rounded-xl bg-sage-600 px-6 text-sm font-medium text-white hover:bg-sage-700">
                            Simpan Pengaturan
                        </button>
                    </div>
                </form>

                @if($tab === UserSettings::TabUmum)
                    <div class="dashboard-card overflow-hidden">
                        <div class="border-b border-gray-100 px-5 py-4">
                            <h2 class="text-[15px] font-semibold text-wedding-ink">Data & Penyimpanan</h2>
                        </div>
                        <div class="divide-y divide-gray-100">
                            <form method="POST" action="{{ route('pengaturan.clear-cache') }}" class="flex items-center justify-between gap-4 px-5 py-4">
                                @csrf
                                <input type="hidden" name="tab" value="{{ $tab }}">
                                <div>
                                    <p class="text-sm font-medium text-wedding-ink">Kosongkan Cache</p>
                                    <p class="mt-0.5 text-xs text-gray-500">Bersihkan data sementara aplikasi</p>
                                </div>
                                <button type="submit" class="rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-xs font-medium text-sage-700 hover:bg-sage-50">
                                    Bersihkan
                                </button>
                            </form>
                            <a href="{{ route('dokumen') }}" class="flex items-center justify-between gap-4 px-5 py-4 hover:bg-gray-50/60">
                                <p class="text-sm font-medium text-wedding-ink">Kelola Penyimpanan</p>
                                <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                                </svg>
                            </a>
                            <button type="button" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left hover:bg-gray-50/60">
                                <p class="text-sm font-medium text-wedding-ink">Backup Data</p>
                                <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                                </svg>
                            </button>
                        </div>
                    </div>
                @endif
            </div>

            {{-- Right sidebar --}}
            <div class="space-y-4 lg:col-span-4">
                <div class="dashboard-card p-6 text-center">
                    <x-dummy-image type="avatar" :alt="$coupleLabel" class="mx-auto h-24 w-24 rounded-full object-cover" />
                    <h2 class="mt-4 text-lg font-semibold text-wedding-ink">{{ $coupleLabel }}</h2>
                    <p class="mt-1 text-sm text-gray-500">{{ $user->email }}</p>
                    @if($user->whatsapp)
                        <p class="mt-0.5 text-sm text-gray-500">{{ $user->whatsapp }}</p>
                    @endif
                    <a href="{{ route('profil') }}#account" class="mt-5 inline-flex h-11 w-full items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white text-sm font-medium text-wedding-ink hover:bg-gray-50">
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                        </svg>
                        Edit Profil
                    </a>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Ringkasan Pengaturan</h3>
                    <dl class="mt-4 space-y-3 text-sm">
                        @foreach([
                            ['label' => 'Bahasa', 'value' => UserSettings::languageLabel($settings['language'])],
                            ['label' => 'Mata Uang', 'value' => UserSettings::currencyLabel($settings['currency'])],
                            ['label' => 'Zona Waktu', 'value' => UserSettings::timezoneLabel($settings['timezone'])],
                            ['label' => 'Mode Gelap', 'value' => UserSettings::boolLabel($settings['dark_mode'])],
                            ['label' => 'Notifikasi Bunyi', 'value' => UserSettings::boolLabel($settings['sound'])],
                            ['label' => 'Getaran', 'value' => UserSettings::boolLabel($settings['vibration'])],
                        ] as $item)
                            <div class="flex items-center justify-between gap-3">
                                <dt class="text-gray-500">{{ $item['label'] }}</dt>
                                <dd class="font-medium text-wedding-ink">{{ $item['value'] }}</dd>
                            </div>
                        @endforeach
                    </dl>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Butuh Bantuan?</h3>
                    <p class="mt-2 text-xs leading-relaxed text-gray-500">Temukan jawaban atau hubungi tim support kami.</p>
                    <div class="mt-4 space-y-2">
                        <a href="{{ route('bantuan') }}" class="flex items-center gap-3 rounded-xl border border-gray-100 px-3 py-3 text-sm text-gray-700 hover:bg-gray-50">
                            @include('components.partials.settings-icon', ['icon' => 'help'])
                            <span class="flex-1">Pusat Bantuan</span>
                            <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                            </svg>
                        </a>
                        <a href="{{ route('bantuan') }}#hubungi" class="flex items-center gap-3 rounded-xl border border-gray-100 px-3 py-3 text-sm text-gray-700 hover:bg-gray-50">
                            @include('components.partials.settings-icon', ['icon' => 'bell'])
                            <span class="flex-1">Hubungi Kami</span>
                            <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                            </svg>
                        </a>
                    </div>
                </div>

                <div class="dashboard-card relative overflow-hidden p-5 text-center">
                    <img src="{{ asset('images/dashboard-floral.svg') }}" alt="" class="pointer-events-none absolute -bottom-2 -right-2 w-28 opacity-40">
                    <p class="relative text-sm font-medium text-wedding-ink">Terima kasih telah mempercayai Wedding App</p>
                    <p class="relative mt-2 text-xs leading-relaxed text-gray-500">Semoga persiapan pernikahanmu berjalan lancar dan penuh kebahagiaan.</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
