@extends('layouts.app')

@section('content')
@php
    use App\Http\Controllers\ProfilController;
    use App\Models\MessageThread;

    $formatRupiah = fn (float $amount): string => 'Rp '.number_format($amount, 0, ',', '.');
    $progressPercent = (int) round(($checklistSummary['progress'] ?? 0) * 100);
    $spentPercent = min($budgetSummary['spent_percent'], 100);
    $remainingPercent = min($budgetSummary['remaining_percent'], 100);
    $checklistTotal = max($checklistSummary['total'], 1);
    $donePercent = (int) round(($checklistSummary['completed'] / $checklistTotal) * 100);
    $inProgressPercent = (int) round(($checklistSummary['in_progress'] / $checklistTotal) * 100);
    $todoPercent = max(0, 100 - $donePercent - $inProgressPercent);

    $dummyTasks = collect([
        ['title' => 'Meeting dengan Vendor Dekorasi', 'date' => now()->addDays(2), 'status' => 'in_progress'],
        ['title' => 'Finalisasi Menu Katering', 'date' => now()->addDays(5), 'status' => 'pending'],
        ['title' => 'Fitting Gaun Pengantin', 'date' => now()->addDays(8), 'status' => 'pending'],
        ['title' => 'Review Undangan Digital', 'date' => now()->addDays(12), 'status' => 'pending'],
    ]);

    $dummyVendors = collect([
        ['name' => 'Bloom Decoration', 'category' => 'Dekorasi', 'confirmed' => true],
        ['name' => 'Aston Palembang Hotel', 'category' => 'Venue', 'confirmed' => true],
        ['name' => 'Luminous Photography', 'category' => 'Fotografi', 'confirmed' => false],
        ['name' => 'Glow Bridal Studio', 'category' => 'Make Up', 'confirmed' => false],
    ]);

    $displayTasks = $upcomingTasks->isNotEmpty() ? $upcomingTasks : $dummyTasks;
    $displayVendors = $recentVendors->isNotEmpty() ? $recentVendors : $dummyVendors;
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Profil Saya</h1>
                <p class="mt-1 text-sm text-gray-500 lg:hidden">Kelola profil dan pengaturan akun pernikahanmu</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <label class="relative hidden xl:block">
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" placeholder="Cari sesuatu..." class="h-11 w-[280px] rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2">
                    <span class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 rounded-md border border-gray-200 bg-gray-50 px-1.5 py-0.5 text-[10px] font-medium text-gray-400">⌘K</span>
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

                <div class="flex items-center gap-2 rounded-xl border border-gray-200 bg-white py-1.5 pl-1.5 pr-3">
                    <x-dummy-image type="avatar" :alt="$coupleLabel" class="h-9 w-9 rounded-full object-cover" />
                    <span class="max-w-[120px] truncate text-sm font-medium text-wedding-ink">{{ $coupleLabel }}</span>
                    <svg class="h-4 w-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                    </svg>
                </div>
            </div>
        </div>

        <div class="grid gap-5 lg:grid-cols-12 lg:gap-6">
            {{-- Main column --}}
            <div class="space-y-5 lg:col-span-8 lg:space-y-6">
                {{-- Welcome banner --}}
                <div class="dashboard-card relative overflow-hidden p-6">
                    <img src="{{ asset('images/dashboard-floral.svg') }}" alt="" class="pointer-events-none absolute bottom-0 right-0 w-[160px] opacity-90 sm:w-[200px]">
                    <div class="relative z-10 max-w-xl">
                        <h2 class="text-xl font-semibold text-wedding-ink lg:text-2xl">Halo {{ $coupleLabel }} 👋</h2>
                        <p class="mt-2 text-sm leading-relaxed text-gray-600">
                            Semangat merencanakan hari bahagiamu! Pantau progres persiapan pernikahanmu di sini.
                        </p>
                        <div class="mt-5 flex flex-wrap gap-x-6 gap-y-2 text-sm text-gray-600">
                            @if($weddingDateLabel)
                                <div class="flex items-center gap-2">
                                    <svg class="h-4 w-4 text-sage-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                                    </svg>
                                    {{ $weddingDateLabel }}
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
                            <div class="flex items-center gap-2">
                                <svg class="h-4 w-4 text-sage-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z" />
                                </svg>
                                {{ $eventTypesLabel }}
                            </div>
                        </div>
                    </div>
                    <x-dummy-image type="couple" alt="Pasangan" class="absolute bottom-0 right-4 hidden h-32 w-32 rounded-2xl object-cover object-top sm:block lg:h-36 lg:w-36" />
                </div>

                {{-- Summary stats --}}
                <div class="grid grid-cols-2 gap-3 lg:grid-cols-4 lg:gap-4">
                    <a href="{{ route('checklist') }}" class="dashboard-card p-4 transition hover:border-sage-200">
                        <div class="flex items-start justify-between">
                            <div>
                                <p class="text-xs font-medium text-gray-500">Checklist</p>
                                <p class="mt-1 text-2xl font-bold text-wedding-ink">{{ $progressPercent }}%</p>
                            </div>
                            <div class="flex h-9 w-9 items-center justify-center rounded-xl bg-sage-50 text-sage-600">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                                </svg>
                            </div>
                        </div>
                        <div class="mt-3 h-1.5 overflow-hidden rounded-full bg-gray-100">
                            <div class="h-full rounded-full bg-sage-500" style="width: {{ $progressPercent }}%"></div>
                        </div>
                        <p class="mt-2 text-[11px] text-gray-500">{{ $checklistSummary['completed'] }} dari {{ $checklistSummary['total'] }} tugas selesai</p>
                    </a>

                    <a href="{{ route('tamu') }}" class="dashboard-card p-4 transition hover:border-sage-200">
                        <div class="flex items-start justify-between">
                            <div>
                                <p class="text-xs font-medium text-gray-500">Guest</p>
                                <p class="mt-1 text-2xl font-bold text-wedding-ink">{{ $guestStats['total'] }}</p>
                            </div>
                            <div class="flex h-9 w-9 items-center justify-center rounded-xl bg-sky-50 text-sky-600">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
                                </svg>
                            </div>
                        </div>
                        <p class="mt-4 text-[11px] text-gray-500"><span class="font-semibold text-sage-700">{{ $guestStats['confirmed'] }}</span> Konfirmasi</p>
                    </a>

                    <a href="{{ route('biaya') }}" class="dashboard-card p-4 transition hover:border-sage-200">
                        <div class="flex items-start justify-between">
                            <div class="min-w-0">
                                <p class="text-xs font-medium text-gray-500">Budget</p>
                                <p class="mt-1 truncate text-lg font-bold text-wedding-ink lg:text-xl">{{ $formatRupiah($budgetSummary['spent']) }}</p>
                            </div>
                            <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-amber-50 text-amber-600">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25m2.25 0v.75a.75.75 0 0 1-.75.75H21m-1.5 0H5.625m1.5 3v2.25m0-6v6m0-6h6m-6 0H9m1.5 0H12m-9.75 0h9.75" />
                                </svg>
                            </div>
                        </div>
                        <p class="mt-2 text-[11px] text-gray-500">{{ $spentPercent }}% dari total anggaran</p>
                    </a>

                    <a href="{{ route('vendor') }}" class="dashboard-card p-4 transition hover:border-sage-200">
                        <div class="flex items-start justify-between">
                            <div>
                                <p class="text-xs font-medium text-gray-500">Vendor</p>
                                <p class="mt-1 text-2xl font-bold text-wedding-ink">{{ $vendorStats['total'] }}</p>
                            </div>
                            <div class="flex h-9 w-9 items-center justify-center rounded-xl bg-rose-50 text-rose-500">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 21v-7.5a.75.75 0 0 1 .75-.75h3a.75.75 0 0 1 .75.75V21m-4.5 0H2.36m11.14 0H18m0 0h3.64m-1.39 0V9.349M3.75 21V9.349m0 0a3.001 3.001 0 0 0 3.75-.615A2.993 2.993 0 0 0 9.75 9.75c.896 0 1.7-.393 2.25-1.016a2.993 2.993 0 0 0 2.25 1.016c.896 0 1.7-.393 2.25-1.016a3.001 3.001 0 0 0 3.75.614m-16.5 0a3.004 3.004 0 0 1-.621-4.72l1.189-1.19A1.5 1.5 0 0 1 5.378 3h13.243a1.5 1.5 0 0 1 1.06.44l1.19 1.189a3 3 0 0 1-.621 4.72M6.75 18h3.75a.75.75 0 0 0 .75-.75V13.5a.75.75 0 0 0-.75-.75H6.75a.75.75 0 0 0-.75.75v3.75c0 .414.336.75.75.75Z" />
                                </svg>
                            </div>
                        </div>
                        <p class="mt-4 text-[11px] text-gray-500"><span class="font-semibold text-sage-700">{{ $vendorStats['confirmed'] }}</span> Dikonfirmasi</p>
                    </a>
                </div>

                {{-- Charts --}}
                <div class="grid gap-4 sm:grid-cols-2">
                    <div class="dashboard-card p-5">
                        <h3 class="text-[15px] font-semibold text-wedding-ink">Progres Checklist</h3>
                        <div class="mt-5 flex items-center gap-5">
                            <div class="relative h-[110px] w-[110px] shrink-0">
                                <svg class="h-[110px] w-[110px] -rotate-90" viewBox="0 0 120 120">
                                    <circle cx="60" cy="60" r="48" fill="none" stroke="#e8ede6" stroke-width="12" />
                                    <circle cx="60" cy="60" r="48" fill="none" stroke="#6b8e6b" stroke-width="12" stroke-linecap="round"
                                            stroke-dasharray="{{ 2 * 3.14159 * 48 }}"
                                            stroke-dashoffset="{{ 2 * 3.14159 * 48 * (1 - $progressPercent / 100) }}" />
                                </svg>
                                <div class="absolute inset-0 flex flex-col items-center justify-center">
                                    <span class="text-2xl font-bold text-sage-800">{{ $progressPercent }}%</span>
                                </div>
                            </div>
                            <div class="space-y-2 text-[12px]">
                                <div class="flex items-center gap-2 text-gray-700">
                                    <span class="h-2.5 w-2.5 rounded-full bg-sage-500"></span>
                                    <span>Selesai</span>
                                    <span class="ml-auto font-medium">{{ $checklistSummary['completed'] }}</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <span class="h-2.5 w-2.5 rounded-full bg-amber-400"></span>
                                    <span>Dalam Proses</span>
                                    <span class="ml-auto font-medium">{{ $checklistSummary['in_progress'] }}</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <span class="h-2.5 w-2.5 rounded-full bg-gray-300"></span>
                                    <span>Belum Mulai</span>
                                    <span class="ml-auto font-medium">{{ $checklistSummary['todo'] }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="dashboard-card p-5">
                        <h3 class="text-[15px] font-semibold text-wedding-ink">Ringkasan Budget</h3>
                        <div class="mt-5 flex items-center gap-5">
                            <div class="relative h-[110px] w-[110px] shrink-0">
                                <svg class="h-[110px] w-[110px] -rotate-90" viewBox="0 0 120 120">
                                    <circle cx="60" cy="60" r="48" fill="none" stroke="#e8ede6" stroke-width="12" />
                                    <circle cx="60" cy="60" r="48" fill="none" stroke="#6b8e6b" stroke-width="12" stroke-linecap="round"
                                            stroke-dasharray="{{ 2 * 3.14159 * 48 }}"
                                            stroke-dashoffset="{{ 2 * 3.14159 * 48 * (1 - $spentPercent / 100) }}" />
                                </svg>
                                <div class="absolute inset-0 flex flex-col items-center justify-center">
                                    <span class="text-2xl font-bold text-sage-800">{{ $spentPercent }}%</span>
                                </div>
                            </div>
                            <div class="min-w-0 space-y-2 text-[12px]">
                                <p class="text-gray-500">Total Anggaran</p>
                                <p class="truncate text-sm font-semibold text-wedding-ink">{{ $formatRupiah($budgetSummary['total_budget']) }}</p>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <span class="h-2.5 w-2.5 rounded-full bg-sage-500"></span>
                                    <span>Terpakai</span>
                                    <span class="ml-auto font-medium">{{ $formatRupiah($budgetSummary['spent']) }}</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <span class="h-2.5 w-2.5 rounded-full bg-gray-300"></span>
                                    <span>Sisa Anggaran</span>
                                    <span class="ml-auto font-medium">{{ $formatRupiah($budgetSummary['remaining']) }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {{-- Lists --}}
                <div class="grid gap-4 sm:grid-cols-2">
                    <div class="dashboard-card p-5">
                        <div class="mb-4 flex items-center justify-between">
                            <h3 class="text-[15px] font-semibold text-wedding-ink">Tugas Mendatang</h3>
                            <a href="{{ route('checklist') }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Semua</a>
                        </div>
                        <div class="space-y-3">
                            @foreach($displayTasks as $task)
                                @php
                                    $isDummy = is_array($task);
                                    $taskTitle = $isDummy ? $task['title'] : $task->title;
                                    $taskDate = $isDummy ? $task['date'] : $task->due_date;
                                    if ($isDummy) {
                                        $badge = $task['status'] === 'in_progress'
                                            ? ['label' => 'Dalam Proses', 'class' => 'bg-amber-50 text-amber-700']
                                            : ['label' => 'Akan Datang', 'class' => 'bg-sky-50 text-sky-700'];
                                    } else {
                                        $badge = ProfilController::taskBadge($task);
                                    }
                                @endphp
                                <div class="flex items-start gap-3 rounded-xl border border-gray-100 p-3">
                                    <div class="min-w-0 flex-1">
                                        <p class="text-[11px] text-gray-400">{{ $taskDate?->translatedFormat('d M Y') }}</p>
                                        <p class="mt-0.5 text-sm font-medium text-wedding-ink">{{ $taskTitle }}</p>
                                    </div>
                                    <span class="shrink-0 rounded-lg px-2 py-1 text-[10px] font-semibold {{ $badge['class'] }}">{{ $badge['label'] }}</span>
                                </div>
                            @endforeach
                        </div>
                    </div>

                    <div class="dashboard-card p-5">
                        <div class="mb-4 flex items-center justify-between">
                            <h3 class="text-[15px] font-semibold text-wedding-ink">Vendor Terbaru</h3>
                            <a href="{{ route('vendor') }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Semua</a>
                        </div>
                        <div class="space-y-3">
                            @foreach($displayVendors as $vendor)
                                @php
                                    $isDummy = is_array($vendor);
                                    if ($isDummy) {
                                        $vendorName = $vendor['name'];
                                        $vendorCategory = $vendor['category'];
                                        $isConfirmed = $vendor['confirmed'];
                                    } elseif ($vendor instanceof MessageThread) {
                                        $vendorName = $vendor->name;
                                        $vendorCategory = $vendor->categoryLabel();
                                        $isConfirmed = ($vendor->messages_count ?? 0) >= 2;
                                    } else {
                                        $vendorName = $vendor->name;
                                        $vendorCategory = $vendor->category?->name ?? 'Vendor';
                                        $isConfirmed = $vendor->is_verified;
                                    }
                                    $vendorBadge = $isConfirmed
                                        ? ['label' => 'Dikonfirmasi', 'class' => 'bg-emerald-50 text-emerald-700']
                                        : ['label' => 'Menunggu', 'class' => 'bg-amber-50 text-amber-700'];
                                @endphp
                                <div class="flex items-center gap-3 rounded-xl border border-gray-100 p-3">
                                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-sage-50 text-xs font-semibold text-sage-700">
                                        {{ strtoupper(substr($vendorName, 0, 2)) }}
                                    </div>
                                    <div class="min-w-0 flex-1">
                                        <p class="truncate text-sm font-medium text-wedding-ink">{{ $vendorName }}</p>
                                        <p class="text-[11px] text-gray-500">{{ $vendorCategory }}</p>
                                    </div>
                                    <span class="shrink-0 rounded-lg px-2 py-1 text-[10px] font-semibold {{ $vendorBadge['class'] }}">{{ $vendorBadge['label'] }}</span>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>

                {{-- Edit forms --}}
                <div class="space-y-5 pt-2 lg:space-y-6">
                    <h2 class="text-lg font-semibold text-wedding-ink">Pengaturan Akun</h2>
                    @include('profil.partials.edit-forms')
                </div>
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
                    <a href="#account" class="mt-5 inline-flex h-11 w-full items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white text-sm font-medium text-wedding-ink hover:bg-gray-50">
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                        </svg>
                        Edit Profil
                    </a>
                </div>

                <div class="dashboard-card overflow-hidden">
                    <div class="border-b border-gray-100 px-5 py-4">
                        <h3 class="text-[15px] font-semibold text-wedding-ink">Pengaturan Akun</h3>
                    </div>
                    <nav class="divide-y divide-gray-50 p-2">
                        @foreach([
                            ['href' => '#account', 'label' => 'Informasi Akun', 'icon' => 'user'],
                            ['href' => '#wedding', 'label' => 'Detail Pernikahan', 'icon' => 'heart'],
                            ['href' => '#account', 'label' => 'Notifikasi', 'icon' => 'bell'],
                            ['href' => route('privacy-policy'), 'label' => 'Privasi & Keamanan', 'icon' => 'shield'],
                            ['href' => '#', 'label' => 'Bahasa', 'icon' => 'globe', 'meta' => 'Indonesia'],
                            ['href' => '#', 'label' => 'Bantuan & Dukungan', 'icon' => 'help'],
                        ] as $item)
                            <a href="{{ $item['href'] }}" class="flex items-center gap-3 rounded-xl px-3 py-3 text-sm text-gray-600 hover:bg-gray-50 hover:text-gray-900">
                                @include('components.partials.settings-icon', ['icon' => $item['icon']])
                                <span class="flex-1">{{ $item['label'] }}</span>
                                @if(isset($item['meta']))
                                    <span class="text-xs text-gray-400">{{ $item['meta'] }}</span>
                                @endif
                                <svg class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                                </svg>
                            </a>
                        @endforeach
                    </nav>
                    <div class="border-t border-gray-100 p-4">
                        <form method="POST" action="{{ route('logout') }}">
                            @csrf
                            <button type="submit" class="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium text-rose-500 hover:bg-rose-50">
                                <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15m-3 0-3-3m0 0 3-3m-3 3H15" />
                                </svg>
                                Keluar Akun
                            </button>
                        </form>
                    </div>
                </div>

                <div class="dashboard-card overflow-hidden bg-gradient-to-br from-sage-50 to-white p-5">
                    <p class="text-xs font-medium uppercase tracking-wide text-sage-600">Paket Berlangganan</p>
                    <h3 class="mt-2 text-lg font-semibold text-wedding-ink">Premium Plan</h3>
                    <p class="mt-1 text-xs leading-relaxed text-gray-500">Akses fitur lengkap untuk perencanaan pernikahan tanpa batas.</p>
                    <button type="button" class="mt-4 inline-flex h-11 w-full items-center justify-center rounded-xl bg-sage-700 text-sm font-medium text-white hover:bg-sage-800">
                        Kelola Paket
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
