@extends('layouts.app')

@section('content')
@php
    $filterUrl = fn (array $params = []): string => route('tamu', array_merge(
        request()->only(['status', 'grup', 'kategori', 'q', 'per_page']),
        $params,
    ));

    $statusBadgeClass = fn (string $status): string => match ($status) {
        'akan_datang' => 'bg-sage-100 text-sage-700',
        'konfirmasi' => 'bg-amber-100 text-amber-700',
        'tidak_hadir' => 'bg-rose-100 text-rose-600',
        default => 'bg-gray-100 text-gray-600',
    };

    $donutCircumference = 2 * 3.14159 * 40;
    $attendingArc = $summary['total'] > 0 ? $donutCircumference * ($summary['akan_datang'] / $summary['total']) : 0;
    $confirmedArc = $summary['total'] > 0 ? $donutCircumference * ($summary['konfirmasi'] / $summary['total']) : 0;
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Guest</h1>
                <p class="mt-1 text-sm text-gray-500">Kelola daftar tamu undangan pernikahan Anda</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <form method="GET" action="{{ route('tamu') }}" class="relative hidden sm:block">
                    @foreach(request()->only(['status', 'grup', 'kategori', 'per_page']) as $key => $value)
                        <input type="hidden" name="{{ $key }}" value="{{ $value }}">
                    @endforeach
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" name="q" value="{{ $search }}" placeholder="Cari tamu..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[280px]">
                    <span class="pointer-events-none absolute right-3 top-1/2 hidden -translate-y-1/2 rounded-md border border-gray-200 bg-gray-50 px-1.5 py-0.5 text-[10px] font-medium text-gray-400 lg:inline">⌘K</span>
                </form>

                <button type="button" class="relative hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
                    </svg>
                    @if($unreadNotifications > 0)
                        <span class="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-semibold text-white">{{ min($unreadNotifications, 9) }}</span>
                    @endif
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

        {{-- Summary cards --}}
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-5 lg:gap-4">
            @foreach([
                ['label' => 'Total Tamu', 'value' => $summary['total'], 'suffix' => 'orang', 'percent' => null, 'status' => null, 'icon' => 'sage'],
                ['label' => 'Akan Datang', 'value' => $summary['akan_datang'], 'suffix' => null, 'percent' => $summary['akan_datang_percent'], 'status' => 'akan_datang', 'icon' => 'sage'],
                ['label' => 'Konfirmasi', 'value' => $summary['konfirmasi'], 'suffix' => null, 'percent' => $summary['konfirmasi_percent'], 'status' => 'konfirmasi', 'icon' => 'amber'],
                ['label' => 'Belum Konfirmasi', 'value' => $summary['belum_konfirmasi'], 'suffix' => null, 'percent' => $summary['belum_konfirmasi_percent'], 'status' => 'belum_konfirmasi', 'icon' => 'gray'],
                ['label' => 'Undangan Terkirim', 'value' => $summary['undangan_terkirim'], 'suffix' => null, 'percent' => $summary['undangan_terkirim_percent'], 'status' => null, 'icon' => 'sage'],
            ] as $card)
                <div class="dashboard-card p-4 lg:p-5">
                    <div class="flex items-start justify-between gap-2">
                        <div class="min-w-0">
                            <p class="truncate text-xs text-gray-500 lg:text-sm">{{ $card['label'] }}</p>
                            <p class="mt-1 text-xl font-bold text-wedding-ink lg:text-2xl">
                                {{ $card['value'] }}
                                @if($card['suffix'])
                                    <span class="text-sm font-normal text-gray-400">{{ $card['suffix'] }}</span>
                                @elseif($card['percent'] !== null)
                                    <span class="text-sm font-medium text-gray-400">({{ $card['percent'] }}%)</span>
                                @endif
                            </p>
                        </div>
                        <div @class([
                            'flex h-8 w-8 shrink-0 items-center justify-center rounded-xl lg:h-9 lg:w-9',
                            'bg-sage-100 text-sage-600' => $card['icon'] === 'sage',
                            'bg-amber-100 text-amber-600' => $card['icon'] === 'amber',
                            'bg-gray-100 text-gray-500' => $card['icon'] === 'gray',
                        ])>
                            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
                            </svg>
                        </div>
                    </div>
                    @if($card['status'])
                        <a href="{{ $filterUrl(['status' => $card['status']]) }}" class="mt-3 inline-flex items-center gap-1 text-xs font-medium text-sage-600 hover:text-sage-700">
                            Lihat Detail →
                        </a>
                    @endif
                </div>
            @endforeach
        </div>

        <div class="grid gap-5 lg:grid-cols-12 lg:gap-6">
            {{-- Main table --}}
            <div class="space-y-4 lg:col-span-8" id="guest-table">
                <div class="dashboard-card overflow-hidden">
                    <div class="flex flex-col gap-3 border-b border-gray-100 p-4 lg:flex-row lg:items-center lg:justify-between">
                        <div class="dashboard-scroll flex gap-1 overflow-x-auto">
                            @foreach($statusTabs as $tab)
                                <a href="{{ $filterUrl(['status' => $tab['key']]) }}"
                                   @class([
                                       'shrink-0 rounded-lg px-4 py-2 text-sm font-medium transition',
                                       'bg-sage-100 text-sage-800' => $activeStatus === $tab['key'],
                                       'text-gray-500 hover:bg-gray-50 hover:text-gray-700' => $activeStatus !== $tab['key'],
                                   ])>
                                    {{ $tab['label'] }}
                                </a>
                            @endforeach
                        </div>

                        <div class="flex flex-wrap items-center gap-2">
                            <button type="button" class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Import</button>
                            <details class="relative">
                                <summary class="flex cursor-pointer list-none items-center gap-1 rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-600 hover:bg-gray-50 [&::-webkit-details-marker]:hidden">Export</summary>
                                <div class="absolute right-0 z-20 mt-2 w-36 rounded-xl border border-gray-100 bg-white p-2 shadow-lg">
                                    <button type="button" class="block w-full rounded-lg px-3 py-2 text-left text-sm text-gray-600 hover:bg-gray-50">CSV</button>
                                    <button type="button" class="block w-full rounded-lg px-3 py-2 text-left text-sm text-gray-600 hover:bg-gray-50">PDF</button>
                                </div>
                            </details>
                            <a href="{{ route('tamu.create') }}" class="inline-flex items-center gap-1.5 rounded-lg bg-sage-600 px-4 py-2 text-sm font-medium text-white hover:bg-sage-700">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                                </svg>
                                Tambah Tamu
                            </a>
                        </div>
                    </div>

                    {{-- Filters --}}
                    <form method="GET" action="{{ route('tamu') }}" class="grid gap-2 border-b border-gray-100 p-4 sm:grid-cols-2 lg:grid-cols-4">
                        <input type="hidden" name="status" value="{{ $activeStatus }}">
                        <input type="hidden" name="per_page" value="{{ $perPage }}">
                        <div class="relative sm:col-span-2 lg:col-span-1">
                            <input type="search" name="q" value="{{ $search }}" placeholder="Cari nama tamu..." class="h-10 w-full rounded-lg border border-gray-200 bg-white px-3 text-sm outline-none focus:ring-2 focus:ring-sage-300">
                        </div>
                        <select name="grup" onchange="this.form.submit()" class="h-10 rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-600">
                            @foreach($grupOptions as $key => $label)
                                <option value="{{ $key }}" @selected($activeGrup === (string) $key)>{{ $label }}</option>
                            @endforeach
                        </select>
                        <select name="kategori" onchange="this.form.submit()" class="h-10 rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-600">
                            @foreach($kategoriOptions as $key => $label)
                                <option value="{{ $key }}" @selected($activeKategori === (string) $key)>{{ $label }}</option>
                            @endforeach
                        </select>
                        <button type="submit" class="h-10 rounded-lg border border-gray-200 bg-white text-sm text-gray-600 hover:bg-gray-50">Terapkan</button>
                    </form>

                    {{-- Desktop table --}}
                    <div class="hidden overflow-x-auto lg:block">
                        <table class="w-full min-w-[720px] text-left text-sm">
                            <thead>
                                <tr class="border-b border-gray-100 text-xs font-medium uppercase tracking-wide text-gray-400">
                                    <th class="px-4 py-3">Nama Tamu</th>
                                    <th class="px-4 py-3">Grup</th>
                                    <th class="px-4 py-3">Kategori</th>
                                    <th class="px-4 py-3">Kontak</th>
                                    <th class="px-4 py-3">Status</th>
                                    <th class="px-4 py-3">Jumlah</th>
                                    <th class="w-20 px-4 py-3">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-50">
                                @forelse($guests as $guest)
                                    <tr class="hover:bg-gray-50/80">
                                        <td class="px-4 py-3.5">
                                            <div class="flex items-center gap-3">
                                                <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-sage-100 text-xs font-semibold text-sage-700">
                                                    {{ $guest['initials'] }}
                                                </div>
                                                <span class="font-medium text-wedding-ink">{{ $guest['name'] }}</span>
                                            </div>
                                        </td>
                                        <td class="px-4 py-3.5 text-gray-600">{{ $guest['grup'] }}</td>
                                        <td class="px-4 py-3.5 text-gray-600">{{ $guest['kategori'] }}</td>
                                        <td class="px-4 py-3.5 text-gray-600">{{ $guest['kontak'] }}</td>
                                        <td class="px-4 py-3.5">
                                            <span class="inline-flex rounded-full px-2.5 py-1 text-xs font-medium {{ $statusBadgeClass($guest['display_status']) }}">
                                                {{ $guest['display_status_label'] }}
                                            </span>
                                        </td>
                                        <td class="px-4 py-3.5 text-gray-600">{{ $guest['jumlah'] }}</td>
                                        <td class="px-4 py-3.5">
                                            <div class="flex items-center gap-1">
                                                <a href="{{ route('tamu.edit', [$guest['tab'], $guest['id']]) }}" class="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-600" title="Lihat">
                                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                                                    </svg>
                                                </a>
                                                <details class="relative">
                                                    <summary class="flex cursor-pointer list-none items-center justify-center rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-600 [&::-webkit-details-marker]:hidden">
                                                        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                                                            <path d="M10 6a2 2 0 1 1 0-4 2 2 0 0 1 0 4ZM10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4ZM10 18a2 2 0 1 1 0-4 2 2 0 0 1 0 4Z"/>
                                                        </svg>
                                                    </summary>
                                                    <div class="absolute right-0 z-20 mt-1 w-40 rounded-xl border border-gray-100 bg-white p-1 shadow-lg">
                                                        <a href="{{ route('tamu.edit', [$guest['tab'], $guest['id']]) }}" class="block rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Edit</a>
                                                        <form method="POST" action="{{ route('tamu.destroy', [$guest['tab'], $guest['id']]) }}" onsubmit="return confirm('Hapus tamu ini?')">
                                                            @csrf @method('DELETE')
                                                            <button type="submit" class="w-full rounded-lg px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50">Hapus</button>
                                                        </form>
                                                    </div>
                                                </details>
                                            </div>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="7" class="px-4 py-12 text-center text-sm text-gray-400">
                                            Belum ada tamu. <a href="{{ route('tamu.create') }}" class="font-medium text-sage-600 hover:underline">Tambah tamu pertama</a>
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>

                    {{-- Mobile list --}}
                    <div class="divide-y divide-gray-50 lg:hidden">
                        @forelse($guests as $guest)
                            <div class="flex gap-3 p-4">
                                <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-sage-100 text-xs font-semibold text-sage-700">
                                    {{ $guest['initials'] }}
                                </div>
                                <div class="min-w-0 flex-1">
                                    <div class="flex items-start justify-between gap-2">
                                        <p class="text-sm font-medium text-wedding-ink">{{ $guest['name'] }}</p>
                                        <span class="shrink-0 rounded-full px-2 py-0.5 text-[10px] font-medium {{ $statusBadgeClass($guest['display_status']) }}">{{ $guest['display_status_label'] }}</span>
                                    </div>
                                    <p class="mt-0.5 text-xs text-gray-400">{{ $guest['grup'] }} · {{ $guest['kategori'] }}</p>
                                    <p class="text-xs text-gray-400">{{ $guest['kontak'] }}</p>
                                </div>
                            </div>
                        @empty
                            <div class="p-8 text-center text-sm text-gray-400">Belum ada tamu.</div>
                        @endforelse
                    </div>

                    @if($guests->total() > 0)
                        <div class="flex flex-col gap-3 border-t border-gray-100 px-4 py-3 text-sm text-gray-500 sm:flex-row sm:items-center sm:justify-between">
                            <p>
                                Menampilkan {{ $guests->firstItem() }}-{{ $guests->lastItem() }} dari {{ $guests->total() }} grup tamu
                            </p>
                            <div class="flex items-center gap-3">
                                <select onchange="window.location.href='{{ $filterUrl(['per_page' => '__PER__']) }}'.replace('__PER__', this.value)" class="rounded-lg border border-gray-200 bg-white px-2 py-1 text-xs">
                                    @foreach([8, 10, 25] as $size)
                                        <option value="{{ $size }}" @selected($perPage === $size)>{{ $size }} / halaman</option>
                                    @endforeach
                                </select>
                                {{ $guests->links() }}
                            </div>
                        </div>
                    @endif
                </div>
            </div>

            {{-- Right panel --}}
            <div class="space-y-4 lg:col-span-4">
                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Statistik Tamu</h3>
                    <div class="mt-4 flex items-center gap-4">
                        <div class="relative h-[100px] w-[100px] shrink-0">
                            <svg class="h-[100px] w-[100px] -rotate-90" viewBox="0 0 100 100">
                                <circle cx="50" cy="50" r="40" fill="none" stroke="#e8ede6" stroke-width="10" />
                                @if($summary['akan_datang'] > 0)
                                    <circle cx="50" cy="50" r="40" fill="none" stroke="#6b8e6b" stroke-width="10" stroke-linecap="round"
                                            stroke-dasharray="{{ $donutCircumference }}"
                                            stroke-dashoffset="{{ $donutCircumference - $attendingArc }}" />
                                @endif
                                @if($summary['konfirmasi'] > 0)
                                    <circle cx="50" cy="50" r="40" fill="none" stroke="#fbbf24" stroke-width="10" stroke-linecap="round"
                                            stroke-dasharray="{{ $donutCircumference }}"
                                            stroke-dashoffset="{{ $donutCircumference - $confirmedArc }}"
                                            transform="rotate({{ $summary['total'] > 0 ? ($summary['akan_datang'] / $summary['total']) * 360 : 0 }} 50 50)" />
                                @endif
                            </svg>
                            <div class="absolute inset-0 flex flex-col items-center justify-center">
                                <span class="text-xl font-bold text-sage-800">{{ $summary['total'] }}</span>
                                <span class="text-[10px] text-sage-500">Total</span>
                            </div>
                        </div>
                        <div class="space-y-2 text-xs">
                            <div class="flex items-center gap-2">
                                <span class="h-2 w-2 rounded-full bg-sage-500"></span>
                                <span class="text-gray-600">Akan Datang</span>
                                <span class="ml-auto font-medium">{{ $summary['akan_datang'] }}</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="h-2 w-2 rounded-full bg-amber-400"></span>
                                <span class="text-gray-600">Konfirmasi</span>
                                <span class="ml-auto font-medium">{{ $summary['konfirmasi'] }}</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="h-2 w-2 rounded-full bg-gray-300"></span>
                                <span class="text-gray-600">Belum Konfirmasi</span>
                                <span class="ml-auto font-medium">{{ $summary['belum_konfirmasi'] }}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="dashboard-card flex items-center gap-3 p-4">
                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-sage-100 text-sage-600">
                        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5" />
                        </svg>
                    </div>
                    <div>
                        <p class="text-sm font-semibold text-wedding-ink">{{ $summary['undangan_terkirim'] }} undangan terkirim</p>
                        <p class="text-xs text-gray-400">{{ $summary['undangan_terkirim_percent'] }}% dari total tamu</p>
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Ringkasan per Grup</h3>
                    <div class="mt-4 space-y-4">
                        @foreach($groupSummary as $group)
                            <div>
                                <div class="flex items-center justify-between text-sm">
                                    <span class="text-gray-700">{{ $group['label'] }}</span>
                                    <span class="text-xs text-gray-400">{{ $group['count'] }} ({{ $group['percent'] }}%)</span>
                                </div>
                                <div class="mt-1.5 h-1.5 overflow-hidden rounded-full bg-gray-100">
                                    <div class="h-full rounded-full bg-sage-500" style="width: {{ $group['percent'] }}%"></div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Aksi Cepat</h3>
                    <div class="mt-4 grid grid-cols-2 gap-2">
                        <a href="{{ route('tamu.create') }}" class="flex flex-col items-center gap-2 rounded-xl border border-gray-100 bg-gray-50 p-3 text-center text-xs font-medium text-gray-700 hover:bg-sage-50 hover:text-sage-700">
                            <svg class="h-5 w-5 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                            </svg>
                            Tambah Tamu
                        </a>
                        <a href="{{ route('tamu.create', ['tab' => 'keluarga']) }}" class="flex flex-col items-center gap-2 rounded-xl border border-gray-100 bg-gray-50 p-3 text-center text-xs font-medium text-gray-700 hover:bg-sage-50 hover:text-sage-700">
                            <svg class="h-5 w-5 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M18 18.72a9.094 9.094 0 0 0 3.741-.479 3 3 0 0 0-4.682-2.72m.94 3.198.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0 1 12 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 0 1 6 18.719m12 0a5.971 5.971 0 0 0-.941-3.197m0 0A5.995 5.995 0 0 0 12 12.75a5.995 5.995 0 0 0-5.058 2.772m0 0a3 3 0 0 0-4.681 2.72 8.986 8.986 0 0 0 3.74.477m.94-3.197a5.971 5.971 0 0 0-.94 3.197M15 6.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm6 3a2.25 2.25 0 1 1-4.5 0 2.25 2.25 0 0 1 4.5 0Zm-13.5 0a2.25 2.25 0 1 1-4.5 0 2.25 2.25 0 0 1 4.5 0Z" />
                            </svg>
                            Buat Grup
                        </a>
                        <button type="button" class="flex flex-col items-center gap-2 rounded-xl border border-gray-100 bg-gray-50 p-3 text-center text-xs font-medium text-gray-700 hover:bg-sage-50 hover:text-sage-700">
                            <svg class="h-5 w-5 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5" />
                            </svg>
                            Kirim Undangan
                        </button>
                        <button type="button" onclick="window.print()" class="flex flex-col items-center gap-2 rounded-xl border border-gray-100 bg-gray-50 p-3 text-center text-xs font-medium text-gray-700 hover:bg-sage-50 hover:text-sage-700">
                            <svg class="h-5 w-5 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096M17.66 18l-1.38-4.171M12 12.75h.008v.008H12v-.008Z" />
                            </svg>
                            Cetak Daftar
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
