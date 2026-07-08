@extends('layouts.app')

@section('content')
@php
    $total = max($summary['total'], 1);
    $progressPercent = (int) round(($summary['progress'] ?? 0) * 100);
    $completedPercent = $summary['total'] > 0 ? (int) round(($summary['completed'] / $summary['total']) * 100) : 0;
    $inProgressPercent = $summary['total'] > 0 ? (int) round(($summary['in_progress'] / $summary['total']) * 100) : 0;
    $todoPercent = $summary['total'] > 0 ? (int) round(($summary['todo'] / $summary['total']) * 100) : 0;

    $filterUrl = fn (array $params = []): string => route('checklist', array_merge(
        request()->only(['category', 'status', 'sort', 'q']),
        $params,
    ));

    $statusBadgeClass = fn (string $status): string => match ($status) {
        'done' => 'bg-sage-100 text-sage-700',
        'in_progress' => 'bg-amber-100 text-amber-700',
        default => 'bg-gray-100 text-gray-600',
    };

    $progressBarClass = fn (string $status): string => match ($status) {
        'done' => 'bg-sage-500',
        'in_progress' => 'bg-amber-400',
        default => 'bg-gray-300',
    };
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Checklist</h1>
                <p class="mt-1 text-sm text-gray-500">Kelola semua tugas persiapan pernikahanmu di satu tempat.</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <form method="GET" action="{{ route('checklist') }}" class="relative hidden sm:block">
                    @foreach(request()->only(['category', 'status', 'sort']) as $key => $value)
                        <input type="hidden" name="{{ $key }}" value="{{ $value }}">
                    @endforeach
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" name="q" value="{{ $search }}" placeholder="Cari tugas, kategori, atau vendor..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[300px] lg:w-[340px]">
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
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-4 lg:gap-4">
            @foreach([
                ['label' => 'Total Tugas', 'value' => $summary['total'], 'percent' => null, 'icon' => 'sage', 'status' => null],
                ['label' => 'Selesai', 'value' => $summary['completed'], 'percent' => $completedPercent, 'icon' => 'sage', 'status' => 'done'],
                ['label' => 'Proses', 'value' => $summary['in_progress'], 'percent' => $inProgressPercent, 'icon' => 'amber', 'status' => 'in_progress'],
                ['label' => 'Belum Mulai', 'value' => $summary['todo'], 'percent' => $todoPercent, 'icon' => 'gray', 'status' => 'pending'],
            ] as $card)
                <div class="dashboard-card p-4 lg:p-5">
                    <div class="flex items-start justify-between gap-2">
                        <div>
                            <p class="text-xs text-gray-500 lg:text-sm">{{ $card['label'] }}</p>
                            <p class="mt-1 text-2xl font-bold text-wedding-ink lg:text-[28px]">
                                {{ $card['value'] }}
                                @if($card['percent'] !== null)
                                    <span class="text-sm font-medium text-gray-400">({{ $card['percent'] }}%)</span>
                                @endif
                            </p>
                        </div>
                        <div @class([
                            'flex h-9 w-9 shrink-0 items-center justify-center rounded-xl',
                            'bg-sage-100 text-sage-600' => $card['icon'] === 'sage',
                            'bg-amber-100 text-amber-600' => $card['icon'] === 'amber',
                            'bg-gray-100 text-gray-500' => $card['icon'] === 'gray',
                        ])>
                            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                            </svg>
                        </div>
                    </div>
                    <a href="{{ $card['status'] ? $filterUrl(['status' => $card['status']]) : '#task-table' }}" class="mt-3 inline-flex items-center gap-1 text-xs font-medium text-sage-600 hover:text-sage-700">
                        Lihat Detail
                        <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" />
                        </svg>
                    </a>
                </div>
            @endforeach
        </div>

        <div class="grid gap-5 lg:grid-cols-12 lg:gap-6">
            {{-- Main column --}}
            <div class="space-y-4 lg:col-span-8" id="task-table">
                {{-- Tabs + actions --}}
                <div class="dashboard-card overflow-hidden">
                    <div class="flex flex-col gap-3 border-b border-gray-100 p-4 lg:flex-row lg:items-center lg:justify-between">
                        <div class="dashboard-scroll flex gap-1 overflow-x-auto">
                            @foreach($categories as $tab)
                                <a href="{{ $filterUrl(['category' => $tab['key'], 'status' => null]) }}"
                                   @class([
                                       'shrink-0 rounded-lg px-4 py-2 text-sm font-medium transition',
                                       'bg-sage-100 text-sage-800' => $activeCategory === $tab['key'],
                                       'text-gray-500 hover:bg-gray-50 hover:text-gray-700' => $activeCategory !== $tab['key'],
                                   ])>
                                    {{ $tab['label'] }}
                                </a>
                            @endforeach
                        </div>

                        <div class="flex flex-wrap items-center gap-2">
                            <details class="relative">
                                <summary class="flex cursor-pointer list-none items-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-600 hover:bg-gray-50 [&::-webkit-details-marker]:hidden">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 3c2.755 0 5.455.232 8.083.678.533.09.917.556.917 1.096v1.044a2.25 2.25 0 0 1-.659 1.591l-5.432 5.432a2.25 2.25 0 0 0-.659 1.591v2.927a2.25 2.25 0 0 1-1.244 2.013L9.75 21v-6.568a2.25 2.25 0 0 0-.659-1.591L3.659 7.409A2.25 2.25 0 0 1 3 5.818V4.774c0-.54.384-1.006.917-1.096A48.32 48.32 0 0 1 12 3Z" />
                                    </svg>
                                    Filter
                                </summary>
                                <div class="absolute right-0 z-20 mt-2 w-44 rounded-xl border border-gray-100 bg-white p-2 shadow-lg">
                                    <a href="{{ $filterUrl(['status' => null]) }}" class="block rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Semua Status</a>
                                    <a href="{{ $filterUrl(['status' => 'done']) }}" class="block rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Selesai</a>
                                    <a href="{{ $filterUrl(['status' => 'in_progress']) }}" class="block rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Proses</a>
                                    <a href="{{ $filterUrl(['status' => 'pending']) }}" class="block rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Belum Mulai</a>
                                </div>
                            </details>

                            <details class="relative">
                                <summary class="flex cursor-pointer list-none items-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-600 hover:bg-gray-50 [&::-webkit-details-marker]:hidden">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 7.5 7.5 3m0 0L12 7.5M7.5 3v13.5m13.5 0L16.5 21m0 0L12 16.5m4.5 4.5V7.5" />
                                    </svg>
                                    Urutkan
                                </summary>
                                <div class="absolute right-0 z-20 mt-2 w-44 rounded-xl border border-gray-100 bg-white p-2 shadow-lg">
                                    @foreach($sortOptions as $key => $label)
                                        <a href="{{ $filterUrl(['sort' => $key]) }}" @class([
                                            'block rounded-lg px-3 py-2 text-sm hover:bg-gray-50',
                                            'bg-sage-50 font-medium text-sage-700' => $activeSort === $key,
                                            'text-gray-600' => $activeSort !== $key,
                                        ])>{{ $label }}</a>
                                    @endforeach
                                </div>
                            </details>

                            <a href="{{ route('checklist.tasks.create') }}" class="inline-flex items-center gap-1.5 rounded-lg bg-sage-600 px-4 py-2 text-sm font-medium text-white hover:bg-sage-700">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                                </svg>
                                Tambah Tugas
                            </a>
                        </div>
                    </div>

                    {{-- Desktop table --}}
                    <div class="hidden overflow-x-auto lg:block">
                        <table class="w-full min-w-[720px] text-left text-sm">
                            <thead>
                                <tr class="border-b border-gray-100 text-xs font-medium uppercase tracking-wide text-gray-400">
                                    <th class="w-10 px-4 py-3"></th>
                                    <th class="px-4 py-3">Tugas</th>
                                    <th class="px-4 py-3">Kategori</th>
                                    <th class="px-4 py-3">Batas Waktu</th>
                                    <th class="px-4 py-3">Status</th>
                                    <th class="px-4 py-3">Progress</th>
                                    <th class="w-12 px-4 py-3"></th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-50">
                                @forelse($tasks as $task)
                                    @php $taskProgress = $task->progressPercent(); @endphp
                                    <tr class="hover:bg-gray-50/80">
                                        <td class="px-4 py-3.5">
                                            <form method="POST" action="{{ route('checklist.tasks.toggle', $task->id) }}">
                                                @csrf @method('PATCH')
                                                <button type="submit" @class([
                                                    'flex h-5 w-5 items-center justify-center rounded border-2 transition',
                                                    'border-sage-500 bg-sage-500' => $task->status === 'done',
                                                    'border-gray-300 hover:border-sage-400' => $task->status !== 'done',
                                                ])>
                                                    @if($task->status === 'done')
                                                        <svg class="h-3 w-3 text-white" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor">
                                                            <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                                        </svg>
                                                    @endif
                                                </button>
                                            </form>
                                        </td>
                                        <td class="px-4 py-3.5">
                                            <p @class(['font-medium text-wedding-ink', 'line-through text-gray-400' => $task->status === 'done'])>{{ $task->title }}</p>
                                            @if($task->description)
                                                <p class="mt-0.5 text-xs text-gray-400">{{ Str::limit($task->description, 60) }}</p>
                                            @elseif($task->label)
                                                <p class="mt-0.5 text-xs text-gray-400">{{ $task->label }}</p>
                                            @endif
                                        </td>
                                        <td class="px-4 py-3.5">
                                            <span class="inline-flex items-center gap-1.5 text-gray-600">
                                                <span class="h-2 w-2 rounded-full bg-sage-400"></span>
                                                {{ $task->categoryLabel() }}
                                            </span>
                                        </td>
                                        <td class="px-4 py-3.5">
                                            @if($task->due_date)
                                                <span @class([
                                                    'inline-flex items-center gap-1 text-gray-600',
                                                    'text-rose-500' => $task->due_date->isPast() && $task->status !== 'done',
                                                ])>
                                                    <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                                                    </svg>
                                                    {{ $task->due_date->translatedFormat('d M Y') }}
                                                </span>
                                            @else
                                                <span class="text-gray-300">—</span>
                                            @endif
                                        </td>
                                        <td class="px-4 py-3.5">
                                            <span class="inline-flex rounded-full px-2.5 py-1 text-xs font-medium {{ $statusBadgeClass($task->status) }}">
                                                {{ $task->statusLabel() }}
                                            </span>
                                        </td>
                                        <td class="px-4 py-3.5">
                                            <div class="flex items-center gap-2">
                                                <span class="w-8 text-xs font-medium text-gray-500">{{ $taskProgress }}%</span>
                                                <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-gray-100">
                                                    <div class="h-full rounded-full {{ $progressBarClass($task->status) }}" style="width: {{ $taskProgress }}%"></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="px-4 py-3.5">
                                            <details class="relative">
                                                <summary class="flex cursor-pointer list-none items-center justify-center rounded-lg p-1 text-gray-400 hover:bg-gray-100 hover:text-gray-600 [&::-webkit-details-marker]:hidden">
                                                    <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                                                        <path d="M10 6a2 2 0 1 1 0-4 2 2 0 0 1 0 4ZM10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4ZM10 18a2 2 0 1 1 0-4 2 2 0 0 1 0 4Z"/>
                                                    </svg>
                                                </summary>
                                                <div class="absolute right-0 z-20 mt-1 w-36 rounded-xl border border-gray-100 bg-white p-1 shadow-lg">
                                                    <a href="{{ route('checklist.tasks.edit', $task->id) }}" class="block rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Edit</a>
                                                    <form method="POST" action="{{ route('checklist.tasks.destroy', $task->id) }}" onsubmit="return confirm('Hapus task ini?')">
                                                        @csrf @method('DELETE')
                                                        <button type="submit" class="w-full rounded-lg px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50">Hapus</button>
                                                    </form>
                                                </div>
                                            </details>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="7" class="px-4 py-12 text-center text-sm text-gray-400">
                                            Belum ada tugas. <a href="{{ route('checklist.tasks.create') }}" class="font-medium text-sage-600 hover:underline">Tambah tugas pertama</a>
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>

                    {{-- Mobile task list --}}
                    <div class="divide-y divide-gray-50 lg:hidden">
                        @forelse($tasks as $task)
                            @php $taskProgress = $task->progressPercent(); @endphp
                            <div class="flex gap-3 p-4">
                                <form method="POST" action="{{ route('checklist.tasks.toggle', $task->id) }}">
                                    @csrf @method('PATCH')
                                    <button type="submit" @class([
                                        'mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded border-2',
                                        'border-sage-500 bg-sage-500' => $task->status === 'done',
                                        'border-gray-300' => $task->status !== 'done',
                                    ])>
                                        @if($task->status === 'done')
                                            <svg class="h-3 w-3 text-white" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                            </svg>
                                        @endif
                                    </button>
                                </form>
                                <div class="min-w-0 flex-1">
                                    <div class="flex items-start justify-between gap-2">
                                        <p @class(['text-sm font-medium', 'line-through text-gray-400' => $task->status === 'done'])>{{ $task->title }}</p>
                                        <span class="shrink-0 rounded-full px-2 py-0.5 text-[10px] font-medium {{ $statusBadgeClass($task->status) }}">{{ $task->statusLabel() }}</span>
                                    </div>
                                    <div class="mt-1 flex flex-wrap items-center gap-2 text-xs text-gray-400">
                                        <span>{{ $task->categoryLabel() }}</span>
                                        @if($task->due_date)
                                            <span>· {{ $task->due_date->translatedFormat('d M Y') }}</span>
                                        @endif
                                    </div>
                                    <div class="mt-2 flex items-center gap-2">
                                        <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-gray-100">
                                            <div class="h-full rounded-full {{ $progressBarClass($task->status) }}" style="width: {{ $taskProgress }}%"></div>
                                        </div>
                                        <span class="text-[10px] text-gray-400">{{ $taskProgress }}%</span>
                                    </div>
                                </div>
                            </div>
                        @empty
                            <div class="p-8 text-center text-sm text-gray-400">Belum ada tugas.</div>
                        @endforelse
                    </div>

                    @if($tasks->hasPages())
                        <div class="flex flex-col gap-3 border-t border-gray-100 px-4 py-3 text-sm text-gray-500 sm:flex-row sm:items-center sm:justify-between">
                            <p>Menampilkan {{ $tasks->firstItem() }}-{{ $tasks->lastItem() }} dari {{ $tasks->total() }} tugas</p>
                            <div>{{ $tasks->links() }}</div>
                        </div>
                    @elseif($tasks->total() > 0)
                        <div class="border-t border-gray-100 px-4 py-3 text-sm text-gray-500">
                            Menampilkan {{ $tasks->total() }} tugas
                        </div>
                    @endif
                </div>

                <div class="flex gap-2 lg:hidden">
                    <a href="{{ route('checklist.events.create') }}" class="flex flex-1 items-center justify-center gap-2 rounded-xl border border-dashed border-gray-200 py-3 text-sm text-gray-500">
                        Tambah Acara
                    </a>
                </div>
            </div>

            {{-- Right sidebar --}}
            <div class="space-y-4 lg:col-span-4">
                {{-- Overall progress --}}
                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Progres Keseluruhan</h3>
                    <div class="mt-4 flex items-center gap-4">
                        <div class="relative h-[100px] w-[100px] shrink-0">
                            <svg class="h-[100px] w-[100px] -rotate-90" viewBox="0 0 100 100">
                                <circle cx="50" cy="50" r="40" fill="none" stroke="#e8ede6" stroke-width="10" />
                                <circle cx="50" cy="50" r="40" fill="none" stroke="#6b8e6b" stroke-width="10" stroke-linecap="round"
                                        stroke-dasharray="{{ 2 * 3.14159 * 40 }}"
                                        stroke-dashoffset="{{ 2 * 3.14159 * 40 * (1 - $progressPercent / 100) }}" />
                            </svg>
                            <div class="absolute inset-0 flex flex-col items-center justify-center">
                                <span class="text-xl font-bold text-sage-800">{{ $progressPercent }}%</span>
                                <span class="text-[10px] text-sage-500">Selesai</span>
                            </div>
                        </div>
                        <div class="space-y-2 text-xs">
                            <div class="flex items-center gap-2">
                                <span class="h-2 w-2 rounded-full bg-sage-500"></span>
                                <span class="text-gray-600">Selesai</span>
                                <span class="ml-auto font-medium">{{ $summary['completed'] }}</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="h-2 w-2 rounded-full bg-amber-400"></span>
                                <span class="text-gray-600">Proses</span>
                                <span class="ml-auto font-medium">{{ $summary['in_progress'] }}</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="h-2 w-2 rounded-full bg-gray-300"></span>
                                <span class="text-gray-600">Belum Mulai</span>
                                <span class="ml-auto font-medium">{{ $summary['todo'] }}</span>
                            </div>
                        </div>
                    </div>
                    <div class="mt-4 rounded-xl bg-sage-50 px-4 py-3 text-center text-xs text-sage-700">
                        Semangat! Kamu sudah menyelesaikan <strong>{{ $progressPercent }}%</strong> dari seluruh persiapan ✨
                    </div>
                </div>

                {{-- Category progress --}}
                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Kategori Checklist</h3>
                    <div class="mt-4 space-y-4">
                        @foreach($eventProgress as $categoryProgress)
                            <div>
                                <div class="flex items-center justify-between text-sm">
                                    <span class="text-gray-700">{{ $categoryProgress['title'] }}</span>
                                    <span class="text-xs text-gray-400">{{ $categoryProgress['done'] }}/{{ $categoryProgress['total'] }}</span>
                                </div>
                                <div class="mt-1.5 h-1.5 overflow-hidden rounded-full bg-gray-100">
                                    <div class="h-full rounded-full bg-sage-500" style="width: {{ $categoryProgress['percent'] }}%"></div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>

                {{-- Upcoming tasks --}}
                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Tugas Mendatang</h3>
                    <div class="mt-4 space-y-3">
                        @forelse($upcomingTasks as $upcoming)
                            <div class="flex gap-3">
                                <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-sage-50 text-sage-600">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                                    </svg>
                                </div>
                                <div class="min-w-0 flex-1">
                                    <p class="truncate text-sm font-medium text-wedding-ink">{{ $upcoming->title }}</p>
                                    <div class="mt-0.5 flex items-center gap-2 text-xs text-gray-400">
                                        <span>{{ $upcoming->due_date?->translatedFormat('d M Y') }}</span>
                                        <span class="rounded-full bg-sage-100 px-2 py-0.5 text-[10px] font-medium text-sage-700">{{ $upcoming->categoryLabel() }}</span>
                                    </div>
                                </div>
                            </div>
                        @empty
                            <p class="text-sm text-gray-400">Tidak ada tugas mendatang.</p>
                        @endforelse
                    </div>
                    <a href="#task-table" class="mt-4 flex h-10 w-full items-center justify-center rounded-xl border border-gray-200 text-sm font-medium text-gray-600 hover:bg-gray-50">
                        Lihat Semua Agenda
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
