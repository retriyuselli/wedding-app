@extends('layouts.app')

@section('content')
@php
    $progressPercent = (int) round(($checklistSummary['progress'] ?? 0) * 100);
    $formatRupiah = fn (float $amount): string => 'Rp '.number_format($amount, 0, ',', '.');
    $spentPercent = min($budgetSummary['spent_percent'], 100);
    $remainingPercent = min($budgetSummary['remaining_percent'], 100);

    $dummyVendors = collect([
        ['name' => 'Aston Palembang Hotel', 'category' => 'Venue'],
        ['name' => 'Makna Wedding Planner', 'category' => 'WO'],
        ['name' => 'Luminous Photography', 'category' => 'Fotografi'],
        ['name' => 'Glow Bridal Studio', 'category' => 'Make Up'],
    ]);

    $dummyInspirations = collect(['Dekorasi Akad', 'Kue Pengantin', 'Gaun Putih']);

    $dummyMessages = collect([
        ['name' => 'Makna Wedding Planner', 'body' => 'Jadwal fitting sudah saya sesuaikan.', 'time' => '10:24', 'unread' => true],
        ['name' => 'Aston Palembang', 'body' => 'Layout ruangan sudah dikonfirmasi.', 'time' => '09:10', 'unread' => true],
        ['name' => 'Glow Bridal Studio', 'body' => 'Trial makeup bisa minggu depan.', 'time' => 'Kemarin', 'unread' => false],
    ]);

    $dummyUpcomingTasks = collect([
        ['title' => 'Meeting dengan Wedding Organizer', 'description' => 'Review rundown dan vendor', 'date' => now()->addDay(), 'label' => 'Besok'],
        ['title' => 'Deposit Catering', 'description' => 'Transfer termin kedua', 'date' => now()->addDays(5), 'label' => '5 hari lagi'],
        ['title' => 'Fitting Baju Pengantin', 'description' => 'Bawa aksesoris tambahan', 'date' => now()->addDays(10), 'label' => '10 hari lagi'],
    ]);

    $displayVendors = $featuredVendors->isNotEmpty() ? $featuredVendors : $dummyVendors;
    $displayInspirations = $savedInspirations->isNotEmpty() ? $savedInspirations : $dummyInspirations;
    $displayMessages = $messageThreads->isNotEmpty() ? $messageThreads : $dummyMessages;
    $displayUpcomingTasks = $upcomingTasks->isNotEmpty() ? $upcomingTasks : $dummyUpcomingTasks;

    $dummyBudgetCategories = collect([
        ['category' => 'Venue', 'allocated' => 45000000, 'spent' => 28000000, 'remaining' => 17000000, 'percent' => 62],
        ['category' => 'Katering', 'allocated' => 35000000, 'spent' => 18000000, 'remaining' => 17000000, 'percent' => 51],
        ['category' => 'Dekorasi', 'allocated' => 25000000, 'spent' => 12000000, 'remaining' => 13000000, 'percent' => 48],
        ['category' => 'Dokumentasi', 'allocated' => 15000000, 'spent' => 8000000, 'remaining' => 7000000, 'percent' => 53],
    ]);

    $displayBudgetCategories = $budgetCategories->isNotEmpty() ? $budgetCategories : $dummyBudgetCategories;

    $guestConfirmedPercent = $guestStats['total'] > 0 ? (int) round(($guestStats['confirmed'] / $guestStats['total']) * 100) : 0;

    $dummyReminders = collect([
        ['title' => 'Final meeting dengan WO', 'due_date' => now()->addDays(3)],
        ['title' => 'Konfirmasi jumlah tamu', 'due_date' => now()->addDays(5)],
        ['title' => 'Bayar termin catering', 'due_date' => now()->addDays(7)],
    ]);

    $displayReminders = $importantReminders->isNotEmpty() ? $importantReminders : $dummyReminders;

    $weatherLocation = $mainLocation ? strtok($mainLocation, ',') : 'Palembang';
    $weddingDayLabel = $countdownEvent?->tgl_acara?->translatedFormat('l, d F Y') ?? 'Tanggal belum diset';
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    {{-- Mobile greeting --}}
    <div class="p-4 lg:hidden">
        <div class="rounded-2xl bg-gradient-to-br from-sage-500 to-sage-700 p-5 text-white">
            <p class="text-sm opacity-90">Selamat datang,</p>
            <h2 class="mt-1 text-xl font-semibold">{{ $coupleLabel }}</h2>
        </div>
    </div>

    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Desktop header --}}
        <div class="hidden items-center justify-between gap-6 lg:flex">
            <div class="min-w-0">
                <h1 class="truncate text-[28px] font-semibold leading-tight text-wedding-ink">
                    Selamat datang, {{ $coupleLabel }}! 👋
                </h1>
                <p class="mt-1 text-sm text-gray-500">Semangat merencanakan hari bahagiamu ✨</p>
            </div>

            <div class="flex shrink-0 items-center gap-3">
                <label class="relative hidden xl:block">
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" placeholder="Cari sesuatu..." class="h-11 w-[280px] rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2">
                    <span class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 rounded-md border border-gray-200 bg-gray-50 px-1.5 py-0.5 text-[10px] font-medium text-gray-400">⌘K</span>
                </label>

                <button type="button" class="relative flex h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
                    </svg>
                    @if($unreadNotifications > 0)
                        <span class="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-semibold text-white">{{ min($unreadNotifications, 9) }}</span>
                    @endif
                </button>

                <button type="button" class="flex h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
                    </svg>
                </button>

                <button type="button" class="flex h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                    </svg>
                </button>

                <a href="{{ route('profil') }}" class="flex items-center gap-2 rounded-xl border border-gray-200 bg-white py-1.5 pl-1.5 pr-3">
                    <x-dummy-image type="avatar" :alt="$coupleLabel" class="h-9 w-9 rounded-full object-cover" />
                    <span class="max-w-[120px] truncate text-sm font-medium text-wedding-ink">{{ $coupleLabel }}</span>
                    <svg class="h-4 w-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                    </svg>
                </a>
            </div>
        </div>

        {{-- Row 1 --}}
        <div class="grid gap-5 lg:grid-cols-12 lg:gap-6">
            <div class="dashboard-card relative min-h-[220px] overflow-hidden p-6 lg:col-span-8">
                <img src="{{ asset('images/dashboard-floral.svg') }}" alt="" class="pointer-events-none absolute bottom-0 right-0 w-[180px] opacity-90 sm:w-[220px]">

                <p class="text-sm font-medium text-sage-600">Hari Pernikahan</p>

                @if($countdownDate && $countdownDate->isFuture())
                    <div id="wedding-countdown" class="relative z-10 mt-5 flex flex-wrap items-end gap-2 lg:gap-3" data-target="{{ $countdownDate->toIso8601String() }}">
                        @foreach(['days' => 'Hari', 'hours' => 'Jam', 'minutes' => 'Menit', 'seconds' => 'Detik'] as $key => $label)
                            @if(!$loop->first)
                                <span class="mb-5 text-3xl font-light text-sage-300 lg:text-4xl">:</span>
                            @endif
                            <div class="text-center">
                                <div @class(['font-bold tabular-nums text-sage-800', 'countdown-'.$key, 'text-4xl lg:text-[52px] leading-none' => true])>--</div>
                                <div class="mt-1 text-xs text-sage-500">{{ $label }}</div>
                            </div>
                        @endforeach
                    </div>
                @else
                    <p class="relative z-10 mt-5 text-4xl font-bold text-sage-800 lg:text-[52px]">Tanggal belum diset</p>
                @endif

                @if($countdownEvent?->tgl_acara)
                    <div class="relative z-10 mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm text-gray-600">
                        <div class="flex items-center gap-2">
                            <svg class="h-4 w-4 text-sage-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                            </svg>
                            {{ $countdownEvent->tgl_acara->translatedFormat('l, d F Y') }}
                        </div>
                        @if($eventTimeLabel)
                            <div class="flex items-center gap-2">
                                <svg class="h-4 w-4 text-sage-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                                </svg>
                                {{ $eventTimeLabel }}
                            </div>
                        @endif
                        @if($mainLocation)
                            <div class="flex items-center gap-2">
                                <svg class="h-4 w-4 text-sage-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 0 1-3 3m0 0a3 3 0 0 1-3-3m3 3V21m4.5-4.5a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                                </svg>
                                {{ $mainLocation }}
                            </div>
                        @endif
                    </div>
                @endif
            </div>

            <div class="dashboard-card flex flex-col p-6 lg:col-span-4">
                <h3 class="text-sm font-semibold text-wedding-ink">Persiapan Keseluruhan</h3>
                <div class="mt-5 flex flex-1 items-center gap-5">
                    <div class="relative h-[120px] w-[120px] shrink-0">
                        <svg class="h-[120px] w-[120px] -rotate-90" viewBox="0 0 120 120">
                            <circle cx="60" cy="60" r="48" fill="none" stroke="#e8ede6" stroke-width="12" />
                            <circle cx="60" cy="60" r="48" fill="none" stroke="#6b8e6b" stroke-width="12" stroke-linecap="round"
                                    stroke-dasharray="{{ 2 * 3.14159 * 48 }}"
                                    stroke-dashoffset="{{ 2 * 3.14159 * 48 * (1 - $progressPercent / 100) }}" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span class="text-[28px] font-bold leading-none text-sage-800">{{ $progressPercent }}%</span>
                            <span class="mt-1 text-[11px] text-sage-500">Selesai</span>
                        </div>
                    </div>
                    <div class="space-y-2.5 text-[13px]">
                        <div class="flex items-center gap-2 text-gray-700">
                            <span class="h-2.5 w-2.5 rounded-full bg-sage-500"></span>
                            <span>Selesai</span>
                            <span class="ml-auto font-medium">{{ $checklistSummary['completed'] }} item</span>
                        </div>
                        <div class="flex items-center gap-2 text-gray-700">
                            <span class="h-2.5 w-2.5 rounded-full bg-amber-400"></span>
                            <span>Proses</span>
                            <span class="ml-auto font-medium">{{ $checklistSummary['in_progress'] }} item</span>
                        </div>
                        <div class="flex items-center gap-2 text-gray-700">
                            <span class="h-2.5 w-2.5 rounded-full bg-gray-300"></span>
                            <span>Belum Mulai</span>
                            <span class="ml-auto font-medium">{{ $checklistSummary['todo'] }} item</span>
                        </div>
                    </div>
                </div>
                <a href="{{ route('checklist') }}" class="mt-5 inline-flex h-11 items-center justify-center rounded-xl bg-sage-600 text-sm font-medium text-white hover:bg-sage-700">
                    Lihat Checklist
                </a>
            </div>
        </div>

        {{-- Quick actions --}}
        <div class="grid grid-cols-3 gap-3 lg:grid-cols-6 lg:gap-4">
            @foreach([
                ['route' => 'profil', 'label' => 'Detail Pernikahan', 'sub' => 'Lihat & edit detail', 'icon' => 'heart'],
                ['route' => 'biaya', 'label' => 'Anggaran', 'sub' => 'Kelola budget', 'icon' => 'wallet'],
                ['route' => 'tamu', 'label' => 'Tamu', 'sub' => 'Kelola tamu', 'icon' => 'users'],
                ['route' => 'checklist', 'label' => 'Dokumen', 'sub' => 'Simpan dokumen', 'icon' => 'doc'],
                ['route' => 'checklist', 'label' => 'Inspirasi', 'sub' => 'Ide & referensi', 'icon' => 'sparkle'],
                ['route' => 'profil', 'label' => 'Pesan', 'sub' => 'Chat vendor', 'icon' => 'chat'],
            ] as $action)
                <a href="{{ route($action['route']) }}" class="dashboard-card flex flex-col items-center px-3 py-4 text-center transition hover:border-sage-200">
                    <div class="mb-3 flex h-12 w-12 items-center justify-center rounded-2xl bg-sage-50 text-sage-700">
                        @include('components.partials.quick-action-icon', ['icon' => $action['icon']])
                    </div>
                    <p class="text-[13px] font-semibold text-wedding-ink">{{ $action['label'] }}</p>
                    <p class="mt-1 hidden text-[11px] leading-tight text-gray-500 sm:block">{{ $action['sub'] }}</p>
                </a>
            @endforeach
        </div>

        {{-- Row 2 --}}
        <div class="grid gap-5 lg:grid-cols-3 lg:gap-6">
            <div class="dashboard-card p-5">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Next Up</h3>
                    <a href="{{ route('checklist') }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Semua</a>
                </div>
                <div class="space-y-3">
                    @foreach($displayUpcomingTasks as $task)
                        @php
                            $isDummyTask = is_array($task);
                            $taskTitle = $isDummyTask ? $task['title'] : $task->title;
                            $taskDescription = $isDummyTask ? $task['description'] : ($task->description ?: 'Persiapan pernikahan');
                            $taskDate = $isDummyTask ? $task['date'] : $task->due_date;
                            $dueLabel = $isDummyTask
                                ? $task['label']
                                : ($task->due_date?->isTomorrow()
                                    ? 'Besok'
                                    : ($task->due_date?->isFuture() && $task->due_date->diffInDays(now()) <= 7
                                        ? $task->due_date->diffInDays(now()).' hari lagi'
                                        : null));
                            $badgeClass = ($dueLabel === 'Besok')
                                ? 'bg-amber-50 text-amber-700'
                                : 'bg-sage-50 text-sage-700';
                        @endphp
                        <div class="flex items-start gap-3 rounded-xl border border-gray-100 p-3">
                            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-sage-50 text-sage-700">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                                </svg>
                            </div>
                            <div class="min-w-0 flex-1">
                                <p class="text-sm font-medium text-wedding-ink">{{ $taskTitle }}</p>
                                <p class="mt-0.5 line-clamp-1 text-xs text-gray-500">{{ $taskDescription }}</p>
                                <p class="mt-1 text-[11px] text-gray-400">{{ $taskDate?->translatedFormat('d M Y') }}</p>
                            </div>
                            @if($dueLabel)
                                <span class="shrink-0 rounded-lg px-2 py-1 text-[10px] font-semibold {{ $badgeClass }}">{{ $dueLabel }}</span>
                            @endif
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="dashboard-card p-5">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Checklist Progress</h3>
                    <a href="{{ route('checklist') }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Semua</a>
                </div>
                <div class="space-y-4">
                    @foreach($eventProgress as $section)
                        <div>
                            <div class="mb-1.5 flex items-center justify-between text-sm">
                                <span class="font-medium text-wedding-ink">{{ $section['title'] }}</span>
                                <span class="text-xs text-gray-500">{{ $section['done'] }} / {{ $section['total'] }}</span>
                            </div>
                            <div class="h-2 overflow-hidden rounded-full bg-sage-100">
                                <div class="h-full rounded-full bg-sage-500" style="width: {{ $section['percent'] }}%"></div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="dashboard-card p-5">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Budget</h3>
                    <a href="{{ route('biaya') }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Detail</a>
                </div>
                <p class="text-xs text-gray-500">Total Anggaran</p>
                <p class="mt-1 text-[26px] font-bold leading-tight text-wedding-ink">{{ $formatRupiah($budgetSummary['total_budget']) }}</p>

                <div class="mt-5 grid grid-cols-2 gap-4 text-sm">
                    <div>
                        <p class="text-xs text-gray-500">Terpakai</p>
                        <p class="mt-1 font-semibold text-sage-700">{{ $formatRupiah($budgetSummary['spent']) }}</p>
                        <p class="text-xs text-gray-400">{{ number_format($budgetSummary['spent_percent'], 2, ',', '.') }}%</p>
                    </div>
                    <div class="text-right">
                        <p class="text-xs text-gray-500">Sisa</p>
                        <p class="mt-1 font-semibold text-gray-700">{{ $formatRupiah($budgetSummary['remaining']) }}</p>
                        <p class="text-xs text-gray-400">{{ number_format($budgetSummary['remaining_percent'], 2, ',', '.') }}%</p>
                    </div>
                </div>

                <div class="mt-4 flex h-2 overflow-hidden rounded-full bg-sage-100">
                    <div class="h-full bg-sage-600" style="width: {{ $spentPercent }}%"></div>
                    <div class="h-full bg-sage-200" style="width: {{ $remainingPercent }}%"></div>
                </div>

                <a href="{{ route('biaya') }}" class="mt-5 inline-flex h-11 w-full items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50">
                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z" />
                    </svg>
                    Kelola Budget
                </a>
            </div>
        </div>

        {{-- Row 4: Vendor + Inspirasi --}}
        <div class="grid gap-5 lg:grid-cols-3 lg:gap-6">
            <div class="dashboard-card p-5 lg:col-span-2">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Vendor Terbaru</h3>
                    <span class="text-xs font-medium text-sage-600">Lihat Semua</span>
                </div>
                <div class="dashboard-scroll -mx-1 flex gap-3 overflow-x-auto px-1 pb-1">
                    @foreach($displayVendors as $vendor)
                        @php
                            $vendorName = is_array($vendor) ? $vendor['name'] : $vendor->name;
                            $vendorCategory = is_array($vendor) ? $vendor['category'] : ($vendor->category?->name ?? 'Vendor');
                        @endphp
                        <div class="w-[150px] shrink-0 overflow-hidden rounded-xl border border-gray-100 bg-white">
                            <div class="relative aspect-[4/3] bg-sage-100">
                                <x-dummy-image type="vendor" :index="$loop->index" :alt="$vendorName" class="h-full w-full object-cover" />
                                <button type="button" class="absolute right-2 top-2 flex h-7 w-7 items-center justify-center rounded-full bg-white/90 text-rose-500 shadow-sm">
                                    <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                                </button>
                            </div>
                            <div class="p-2.5">
                                <p class="truncate text-xs font-semibold text-wedding-ink">{{ $vendorName }}</p>
                                <p class="truncate text-[10px] text-gray-500">{{ $vendorCategory }}</p>
                                <div class="mt-1 flex items-center gap-1 text-[10px] text-amber-500">
                                    <svg class="h-3 w-3 fill-current" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                                    <span class="font-medium">4.8</span>
                                    <span class="text-gray-400">(120)</span>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="dashboard-card p-5">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Inspirasi Pilihan</h3>
                    <span class="text-xs font-medium text-sage-600">Lihat Semua</span>
                </div>
                <div class="grid grid-cols-3 gap-2">
                    @foreach($displayInspirations as $inspiration)
                        @php
                            $inspirationTitle = is_string($inspiration) ? $inspiration : $inspiration->title;
                        @endphp
                        <div class="relative aspect-[3/4] overflow-hidden rounded-xl bg-sage-100">
                            <x-dummy-image type="inspiration" :index="$loop->index" :alt="$inspirationTitle" class="h-full w-full object-cover" />
                            <button type="button" class="absolute right-1.5 top-1.5 flex h-6 w-6 items-center justify-center rounded-full bg-white/90 text-rose-500">
                                <svg class="h-3.5 w-3.5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                            </button>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>

        {{-- Row 5: Anggaran per Kategori + Pesan --}}
        <div class="grid gap-5 lg:grid-cols-3 lg:gap-6">
            <div class="dashboard-card overflow-hidden p-5 lg:col-span-2">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Anggaran per Kategori</h3>
                    <a href="{{ route('biaya') }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Detail</a>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full min-w-[520px] text-left text-sm">
                        <thead>
                            <tr class="border-b border-gray-100 text-xs text-gray-500">
                                <th class="pb-3 font-medium">Kategori</th>
                                <th class="pb-3 font-medium">Anggaran</th>
                                <th class="pb-3 font-medium">Terpakai</th>
                                <th class="pb-3 font-medium">Sisa</th>
                                <th class="pb-3 font-medium">Progress</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50">
                            @foreach($displayBudgetCategories as $row)
                                @php
                                    $category = is_array($row) ? $row['category'] : $row['category'];
                                    $allocated = is_array($row) ? $row['allocated'] : $row['allocated'];
                                    $spent = is_array($row) ? $row['spent'] : $row['spent'];
                                    $remaining = is_array($row) ? $row['remaining'] : $row['remaining'];
                                    $percent = is_array($row) ? $row['percent'] : $row['percent'];
                                @endphp
                                <tr>
                                    <td class="py-3 font-medium text-wedding-ink">{{ $category }}</td>
                                    <td class="py-3 text-gray-600">{{ $formatRupiah($allocated) }}</td>
                                    <td class="py-3 text-sage-700">{{ $formatRupiah($spent) }}</td>
                                    <td class="py-3 text-gray-600">{{ $formatRupiah($remaining) }}</td>
                                    <td class="py-3">
                                        <div class="flex items-center gap-2">
                                            <div class="h-1.5 w-20 overflow-hidden rounded-full bg-sage-100">
                                                <div class="h-full rounded-full bg-sage-500" style="width: {{ $percent }}%"></div>
                                            </div>
                                            <span class="text-xs text-gray-400">{{ $percent }}%</span>
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="dashboard-card p-5">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Pesan Terbaru</h3>
                    <span class="text-xs font-medium text-sage-600">Lihat Semua</span>
                </div>
                <div class="space-y-3">
                    @foreach($displayMessages as $thread)
                        @php
                            $isDummy = is_array($thread);
                            $threadName = $isDummy ? $thread['name'] : $thread->name;
                            $threadBody = $isDummy ? $thread['body'] : ($thread->latestMessage?->body ?? 'Belum ada pesan');
                            $threadTime = $isDummy ? $thread['time'] : ($thread->latestMessage?->created_at->format('H:i'));
                            $threadUnread = $isDummy
                                ? ($thread['unread'] ?? false)
                                : ($thread->latestMessage && ! $thread->latestMessage->is_outgoing && is_null($thread->latestMessage->read_at));
                        @endphp
                        <div class="flex items-center gap-3">
                            <x-dummy-image type="message" :index="$loop->index" :alt="$threadName" class="h-10 w-10 shrink-0 rounded-full object-cover" />
                            <div class="min-w-0 flex-1">
                                <div class="flex items-center justify-between gap-2">
                                    <p class="truncate text-sm font-medium text-wedding-ink">{{ $threadName }}</p>
                                    @if($threadTime)
                                        <span class="shrink-0 text-[10px] text-gray-400">{{ $threadTime }}</span>
                                    @endif
                                </div>
                                <p class="truncate text-xs text-gray-500">{{ $threadBody }}</p>
                            </div>
                            @if($threadUnread)
                                <span class="h-2.5 w-2.5 shrink-0 rounded-full bg-sage-500"></span>
                            @endif
                        </div>
                    @endforeach
                </div>
            </div>
        </div>

        {{-- Row 6: Tamu, Pengingat, Cuaca --}}
        <div class="grid gap-5 lg:grid-cols-3 lg:gap-6">
            <div class="dashboard-card p-5">
                <h3 class="text-[15px] font-semibold text-wedding-ink">Tamu Undangan</h3>
                <div class="mt-4 flex items-center gap-5">
                    @php
                        $confirmedArc = 2 * 3.14159 * 42 * ($guestConfirmedPercent / 100);
                        $circumference = 2 * 3.14159 * 42;
                    @endphp
                    <div class="relative h-24 w-24 shrink-0">
                        <svg class="h-24 w-24 -rotate-90" viewBox="0 0 100 100">
                            <circle cx="50" cy="50" r="42" fill="none" stroke="#e8ede6" stroke-width="10" />
                            <circle cx="50" cy="50" r="42" fill="none" stroke="#6b8e6b" stroke-width="10" stroke-linecap="round"
                                    stroke-dasharray="{{ $circumference }}"
                                    stroke-dashoffset="{{ $circumference - $confirmedArc }}" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span class="text-lg font-bold text-sage-800">{{ $guestStats['total'] }}</span>
                            <span class="text-[10px] text-gray-500">Total</span>
                        </div>
                    </div>
                    <div class="space-y-2 text-xs text-gray-600">
                        <div class="flex items-center gap-2"><span class="h-2 w-2 rounded-full bg-sage-500"></span> Konfirmasi ({{ $guestStats['confirmed'] }})</div>
                        <div class="flex items-center gap-2"><span class="h-2 w-2 rounded-full bg-amber-400"></span> Belum Konfirmasi ({{ $guestStats['awaiting'] }})</div>
                        <div class="flex items-center gap-2"><span class="h-2 w-2 rounded-full bg-gray-300"></span> Tidak Hadir ({{ $guestStats['declined'] }})</div>
                    </div>
                </div>
            </div>

            <div class="dashboard-card p-5">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Pengingat Penting</h3>
                    <a href="{{ route('checklist') }}" class="text-xs font-medium text-sage-600">Lihat Semua</a>
                </div>
                <div class="space-y-2.5">
                    @foreach($displayReminders as $reminder)
                        @php
                            $isDummyReminder = is_array($reminder);
                            $reminderTitle = $isDummyReminder ? $reminder['title'] : $reminder->title;
                            $reminderDate = $isDummyReminder ? $reminder['due_date'] : $reminder->due_date;
                            $daysLeft = $reminderDate ? (int) now()->startOfDay()->diffInDays($reminderDate->startOfDay(), false) : null;
                        @endphp
                        <div class="flex items-center justify-between gap-2 rounded-lg border border-gray-100 px-3 py-2">
                            <p class="truncate text-sm text-wedding-ink">{{ $reminderTitle }}</p>
                            @if($daysLeft !== null && $daysLeft >= 0)
                                <span class="shrink-0 rounded-md bg-amber-50 px-2 py-0.5 text-[10px] font-semibold text-amber-700">{{ $daysLeft }} hari lagi</span>
                            @endif
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="dashboard-card p-5">
                <h3 class="text-[15px] font-semibold text-wedding-ink">Cuaca Pernikahan</h3>
                <p class="mt-1 text-xs text-gray-500">{{ $weatherLocation }} · {{ $weddingDayLabel }}</p>
                <div class="mt-4 flex items-center gap-3">
                    <div class="text-4xl">⛅</div>
                    <div>
                        <p class="text-3xl font-bold text-wedding-ink">32°C</p>
                        <p class="text-xs text-gray-500">Cerah berawan · Kelembapan 68%</p>
                    </div>
                </div>
                <div class="mt-4 grid grid-cols-4 gap-2 text-center text-[10px] text-gray-500">
                    @foreach([['Min', 31], ['Sel', 32], ['Rab', 33], ['Kam', 32]] as [$day, $temp])
                        <div class="rounded-lg bg-sage-50 py-2">
                            <p>{{ $day }}</p>
                            <p class="mt-1 text-sm font-semibold text-sage-700">{{ $temp }}°</p>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>

        {{-- Row 7: Tips --}}
        <div class="dashboard-card relative overflow-hidden p-6">
            <div class="absolute inset-0 bg-gradient-to-r from-sage-700/90 to-sage-600/80"></div>
            <x-dummy-image type="inspiration" :index="1" alt="" class="absolute inset-0 h-full w-full object-cover opacity-30" />
            <div class="relative z-10 max-w-2xl text-white">
                <p class="text-sm font-semibold">Tips Hari Ini</p>
                <p class="mt-2 text-sm leading-relaxed opacity-95">
                    {{ $dailyQuote ?? 'Mulai finalisasi timeline acara 2-3 bulan sebelum hari H agar semua vendor punya waktu persiapan yang cukup.' }}
                </p>
            </div>
        </div>
    </div>

    <x-dashboard-footer />
</div>
@endsection
