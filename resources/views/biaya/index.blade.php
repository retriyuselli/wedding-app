@extends('layouts.app')

@section('content')
@php
    $formatRupiah = fn (float $amount): string => 'Rp '.number_format($amount, 0, ',', '.');
    $filterUrl = fn (array $params = []): string => route('biaya', array_merge(
        request()->only(['tab', 'filter']),
        $params,
    ));
    $spentPercent = $budgetSummary['spent_percent'];
    $remainingPercent = $budgetSummary['remaining_percent'];
    $donutCircumference = 2 * 3.14159 * 40;
    $chartOffset = 0;
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Budget</h1>
                <p class="mt-1 text-sm text-gray-500">Pantau anggaran pernikahan dan pengeluaran Anda</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <div class="relative hidden sm:block">
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" placeholder="Cari transaksi..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[280px]">
                    <span class="pointer-events-none absolute right-3 top-1/2 hidden -translate-y-1/2 rounded-md border border-gray-200 bg-gray-50 px-1.5 py-0.5 text-[10px] font-medium text-gray-400 lg:inline">⌘K</span>
                </div>

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
            <div class="dashboard-card p-4 lg:p-5">
                <p class="text-xs text-gray-500 lg:text-sm">Total Anggaran</p>
                <p class="mt-1 text-lg font-bold text-wedding-ink lg:text-2xl">{{ $formatRupiah($budgetSummary['total_budget']) }}</p>
                <a href="{{ route('biaya.budget') }}" class="mt-3 inline-flex items-center gap-1 text-xs font-medium text-sage-600 hover:text-sage-700">
                    <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                    </svg>
                    Edit Anggaran
                </a>
            </div>

            <div class="dashboard-card p-4 lg:p-5">
                <p class="text-xs text-gray-500 lg:text-sm">Terpakai</p>
                <p class="mt-1 text-lg font-bold text-wedding-ink lg:text-2xl">{{ $formatRupiah($budgetSummary['spent']) }}</p>
                <p class="mt-1 text-xs text-gray-400">{{ number_format($spentPercent, 2, ',', '.') }}% dari anggaran</p>
            </div>

            <div class="dashboard-card p-4 lg:p-5">
                <p class="text-xs text-gray-500 lg:text-sm">Sisa Anggaran</p>
                <p class="mt-1 text-lg font-bold text-sage-700 lg:text-2xl">{{ $formatRupiah($budgetSummary['remaining']) }}</p>
                <p class="mt-1 text-xs text-gray-400">{{ number_format($remainingPercent, 2, ',', '.') }}% dari anggaran</p>
            </div>

            <div class="dashboard-card p-4 lg:p-5">
                <p class="text-xs text-gray-500 lg:text-sm">Progres Penggunaan</p>
                <p class="mt-1 text-lg font-bold text-wedding-ink lg:text-2xl">{{ number_format($spentPercent, 2, ',', '.') }}%</p>
                <div class="mt-3 h-2 overflow-hidden rounded-full bg-gray-100">
                    <div class="h-full rounded-full bg-sage-600" style="width: {{ min($spentPercent, 100) }}%"></div>
                </div>
            </div>
        </div>

        <div class="grid gap-5 lg:grid-cols-12 lg:gap-6">
            {{-- Main content --}}
            <div class="space-y-4 lg:col-span-8">
                <div class="dashboard-card overflow-hidden">
                    <div class="flex flex-col gap-3 border-b border-gray-100 p-4 lg:flex-row lg:items-center lg:justify-between">
                        <div class="dashboard-scroll flex gap-4 overflow-x-auto border-b border-transparent lg:border-0">
                            @foreach($tabs as $tabItem)
                                <a href="{{ $filterUrl(['tab' => $tabItem['key']]) }}"
                                   @class([
                                       'shrink-0 border-b-2 pb-2 text-sm font-medium transition',
                                       'border-sage-600 text-sage-700' => $activeTab === $tabItem['key'],
                                       'border-transparent text-gray-500 hover:text-gray-700' => $activeTab !== $tabItem['key'],
                                   ])>
                                    {{ $tabItem['label'] }}
                                </a>
                            @endforeach
                        </div>

                        <div class="flex flex-wrap items-center gap-2">
                            @if($activeTab === 'transaksi')
                                <div class="dashboard-scroll flex gap-1 overflow-x-auto">
                                    @foreach(['semua' => 'Semua', 'belum' => 'Belum Bayar', 'sudah' => 'Sudah Bayar', 'overdue' => 'Overdue'] as $key => $label)
                                        <a href="{{ $filterUrl(['tab' => 'transaksi', 'filter' => $key]) }}"
                                           @class([
                                               'shrink-0 rounded-lg px-3 py-1.5 text-xs font-medium',
                                               'bg-sage-100 text-sage-700' => $filter === $key,
                                               'bg-gray-100 text-gray-600' => $filter !== $key,
                                           ])>{{ $label }}</a>
                                    @endforeach
                                </div>
                            @endif

                            <button type="button" class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Filter</button>
                            <button type="button" class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-600 hover:bg-gray-50">Export</button>
                            <a href="{{ route('biaya.create') }}" class="inline-flex items-center gap-1.5 rounded-lg bg-sage-600 px-4 py-2 text-sm font-medium text-white hover:bg-sage-700">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                                </svg>
                                Tambah Pengeluaran
                            </a>
                        </div>
                    </div>

                    @if(in_array($activeTab, ['ringkasan', 'kategori'], true))
                        @if($categoryRows->isEmpty())
                            <div class="p-8 text-center text-sm text-gray-400">
                                <p>Belum ada kategori anggaran.</p>
                                <p class="mt-2">
                                    <a href="{{ route('biaya.budget') }}" class="font-medium text-sage-600 hover:underline">Atur total anggaran</a>
                                    <span class="text-gray-300">·</span>
                                    <a href="{{ route('biaya.create') }}" class="font-medium text-sage-600 hover:underline">Tambah pengeluaran</a>
                                </p>
                            </div>
                        @else
                        <div class="hidden overflow-x-auto lg:block">
                            <table class="w-full min-w-[720px] text-left text-sm">
                                <thead>
                                    <tr class="border-b border-gray-100 text-xs font-medium uppercase tracking-wide text-gray-400">
                                        <th class="px-4 py-3">Kategori</th>
                                        <th class="px-4 py-3">Anggaran</th>
                                        <th class="px-4 py-3">Terpakai</th>
                                        <th class="px-4 py-3">Sisa</th>
                                        <th class="px-4 py-3">Progres</th>
                                        <th class="w-12 px-4 py-3"></th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-50">
                                    @foreach($categoryRows as $row)
                                        <tr class="hover:bg-gray-50/80">
                                            <td class="px-4 py-3.5">
                                                <div class="flex items-center gap-3">
                                                    <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl" style="background-color: {{ $row['color'] }}22; color: {{ $row['color'] }}">
                                                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 21v-3.375c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21M3 3h12m-.75 4.5H21m-3.75 3.75h.008v.008H17.25v-.008Zm0 3h.008v.008H17.25v-.008Zm0 3h.008v.008H17.25v-.008Z" />
                                                        </svg>
                                                    </div>
                                                    <div>
                                                        <p class="font-medium text-wedding-ink">{{ $row['category'] }}</p>
                                                        <p class="text-xs text-gray-400">{{ $row['description'] }}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-4 py-3.5 text-gray-700">{{ $formatRupiah($row['allocated']) }}</td>
                                            <td class="px-4 py-3.5 text-gray-700">{{ $formatRupiah($row['spent']) }}</td>
                                            <td class="px-4 py-3.5 text-sage-700">{{ $formatRupiah($row['remaining']) }}</td>
                                            <td class="px-4 py-3.5">
                                                <div class="flex items-center gap-2">
                                                    <span class="w-8 text-xs font-medium text-gray-500">{{ $row['percent'] }}%</span>
                                                    <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-gray-100">
                                                        <div class="h-full rounded-full bg-sage-500" style="width: {{ $row['percent'] }}%"></div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-4 py-3.5">
                                                <button type="button" class="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100">
                                                    <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                                                        <path d="M10 6a2 2 0 1 1 0-4 2 2 0 0 1 0 4ZM10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4ZM10 18a2 2 0 1 1 0-4 2 2 0 0 1 0 4Z"/>
                                                    </svg>
                                                </button>
                                            </td>
                                        </tr>
                                    @endforeach
                                </tbody>
                                <tfoot>
                                    <tr class="bg-sage-50 font-medium text-wedding-ink">
                                        <td class="px-4 py-3.5">Total Keseluruhan</td>
                                        <td class="px-4 py-3.5">{{ $formatRupiah($categoryTotals['allocated']) }}</td>
                                        <td class="px-4 py-3.5">{{ $formatRupiah($categoryTotals['spent']) }}</td>
                                        <td class="px-4 py-3.5 text-sage-700">{{ $formatRupiah($categoryTotals['remaining']) }}</td>
                                        <td class="px-4 py-3.5">{{ $categoryTotals['percent'] }}%</td>
                                        <td></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <div class="divide-y divide-gray-50 lg:hidden">
                            @foreach($categoryRows as $row)
                                <div class="p-4">
                                    <div class="flex items-center justify-between gap-2">
                                        <p class="font-medium text-wedding-ink">{{ $row['category'] }}</p>
                                        <span class="text-xs text-gray-400">{{ $row['percent'] }}%</span>
                                    </div>
                                    <p class="mt-0.5 text-xs text-gray-400">{{ $row['description'] }}</p>
                                    <div class="mt-2 grid grid-cols-3 gap-2 text-xs">
                                        <div><span class="text-gray-400">Anggaran</span><p class="font-medium">{{ $formatRupiah($row['allocated']) }}</p></div>
                                        <div><span class="text-gray-400">Terpakai</span><p class="font-medium">{{ $formatRupiah($row['spent']) }}</p></div>
                                        <div><span class="text-gray-400">Sisa</span><p class="font-medium text-sage-700">{{ $formatRupiah($row['remaining']) }}</p></div>
                                    </div>
                                </div>
                            @endforeach
                        </div>

                        <div class="border-t border-gray-100 px-4 py-3 text-sm text-gray-500">
                            1-{{ $categoryRows->count() }} dari {{ $categoryRows->count() }} kategori
                        </div>
                        @endif
                    @endif

                    @if($activeTab === 'transaksi')
                        <div class="divide-y divide-gray-50">
                            @forelse($schedules as $schedule)
                                <div class="flex items-start justify-between gap-3 p-4 hover:bg-gray-50/80">
                                    <div class="min-w-0 flex-1">
                                        <div class="flex flex-wrap items-center gap-2">
                                            <p class="text-sm font-medium text-wedding-ink">{{ $schedule->title }}</p>
                                            <span @class([
                                                'rounded-full px-2 py-0.5 text-[10px] font-medium',
                                                'bg-sage-100 text-sage-700' => $schedule->status === 'paid',
                                                'bg-rose-100 text-rose-600' => $schedule->status === 'overdue',
                                                'bg-amber-100 text-amber-700' => $schedule->status === 'pending',
                                            ])>{{ $schedule->status_label }}</span>
                                        </div>
                                        <p class="mt-0.5 text-xs text-gray-400">
                                            {{ $schedule->vendor_name ?: $schedule->category_label }}
                                            @if($schedule->due_date) · {{ $schedule->due_date->translatedFormat('d M Y') }} @endif
                                        </p>
                                    </div>
                                    <div class="flex shrink-0 flex-col items-end gap-2">
                                        <p class="text-sm font-semibold text-rose-600">-{{ $formatRupiah((float) $schedule->amount) }}</p>
                                        <div class="flex items-center gap-1">
                                            <a href="{{ route('biaya.edit', $schedule->id) }}" class="rounded-lg p-1 text-gray-400 hover:bg-gray-100">
                                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                                                </svg>
                                            </a>
                                            @if($schedule->status !== 'paid')
                                                <form method="POST" action="{{ route('biaya.markPaid', $schedule->id) }}">
                                                    @csrf @method('PATCH')
                                                    <button type="submit" class="rounded-lg bg-sage-50 px-2 py-1 text-[10px] font-medium text-sage-700 hover:bg-sage-100">Lunas</button>
                                                </form>
                                            @endif
                                        </div>
                                    </div>
                                </div>
                            @empty
                                <div class="p-8 text-center text-sm text-gray-400">
                                    Belum ada transaksi. <a href="{{ route('biaya.create') }}" class="font-medium text-sage-600 hover:underline">Tambah pengeluaran</a>
                                </div>
                            @endforelse
                        </div>
                    @endif

                    @if($activeTab === 'pemasukan')
                        <div class="divide-y divide-gray-50">
                            @forelse($incomingPayments as $payment)
                                <div class="flex items-start justify-between gap-3 p-4 hover:bg-gray-50/80">
                                    <div class="min-w-0 flex-1">
                                        <p class="text-sm font-medium text-wedding-ink">{{ $payment->sender_name ?: 'Pemasukan' }}</p>
                                        <p class="mt-0.5 text-xs text-gray-400">
                                            {{ $payment->bank_name ?: 'Transfer' }}
                                            @if($payment->transfer_date) · {{ $payment->transfer_date->translatedFormat('d M Y') }} @endif
                                        </p>
                                        @if($payment->description)
                                            <p class="mt-1 text-xs text-gray-500">{{ $payment->description }}</p>
                                        @endif
                                    </div>
                                    <div class="text-right">
                                        <p class="text-sm font-semibold text-sage-700">+{{ $formatRupiah((float) $payment->amount) }}</p>
                                        <span @class([
                                            'mt-1 inline-block rounded-full px-2 py-0.5 text-[10px] font-medium',
                                            'bg-sage-100 text-sage-700' => $payment->status === 'confirmed',
                                            'bg-rose-100 text-rose-600' => $payment->status === 'rejected',
                                            'bg-amber-100 text-amber-700' => $payment->status === 'menunggu',
                                        ])>{{ $payment->status_label }}</span>
                                    </div>
                                </div>
                            @empty
                                <div class="p-8 text-center text-sm text-gray-400">
                                    Belum ada pemasukan. <a href="{{ route('uang-masuk.create') }}" class="font-medium text-sage-600 hover:underline">Catat uang masuk</a>
                                </div>
                            @endforelse
                        </div>
                    @endif
                </div>
            </div>

            {{-- Right sidebar --}}
            <div class="space-y-4 lg:col-span-4">
                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Ringkasan Grafik</h3>
                    <div class="mt-4 flex items-center gap-4">
                        <div class="relative h-[100px] w-[100px] shrink-0">
                            <svg class="h-[100px] w-[100px] -rotate-90" viewBox="0 0 100 100">
                                <circle cx="50" cy="50" r="40" fill="none" stroke="#e8ede6" stroke-width="10" />
                                @php $chartOffset = 0; @endphp
                                @foreach($chartSegments as $segment)
                                    @php
                                        $arc = $donutCircumference * ($segment['percent'] / 100);
                                        $currentOffset = $chartOffset;
                                        $chartOffset += $arc;
                                    @endphp
                                    <circle cx="50" cy="50" r="40" fill="none" stroke="{{ $segment['color'] }}" stroke-width="10" stroke-linecap="round"
                                            stroke-dasharray="{{ $donutCircumference }}"
                                            stroke-dashoffset="{{ $donutCircumference - $arc }}"
                                            transform="rotate({{ ($currentOffset / $donutCircumference) * 360 }} 50 50)" />
                                @endforeach
                            </svg>
                            <div class="absolute inset-0 flex flex-col items-center justify-center px-2 text-center">
                                <span class="text-[10px] leading-tight text-sage-500">Total</span>
                                <span class="text-[11px] font-bold leading-tight text-sage-800">{{ $formatRupiah($budgetSummary['total_budget']) }}</span>
                            </div>
                        </div>
                        <div class="space-y-2 text-xs">
                            @forelse($chartSegments as $segment)
                                <div class="flex items-center gap-2">
                                    <span class="h-2 w-2 rounded-full" style="background-color: {{ $segment['color'] }}"></span>
                                    <span class="text-gray-600">{{ $segment['label'] }}</span>
                                    <span class="ml-auto font-medium">{{ $segment['percent'] }}%</span>
                                </div>
                            @empty
                                <p class="text-gray-400">Belum ada data pengeluaran per kategori.</p>
                            @endforelse
                        </div>
                    </div>
                </div>

                <div class="dashboard-card overflow-hidden p-5">
                    <div class="flex items-start gap-3">
                        <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-amber-100 text-amber-600">
                            <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 18v-5.25m0 0a6.01 6.01 0 0 0 1.5-.189m-1.5.189a6.01 6.01 0 0 1-1.5-.189m3.75 7.478a12.06 12.06 0 0 1-4.5 0m4.5 0a12.06 12.06 0 0 0-4.5 0m0 0a8.997 8.997 0 0 1 3.75-7.5M12 3v2.25" />
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-sm font-semibold text-wedding-ink">Tips Hemat</h3>
                            <p class="mt-1 text-xs leading-relaxed text-gray-500">{{ $savingsTip }}</p>
                        </div>
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Transaksi Terbaru</h3>
                    <div class="mt-4 space-y-3">
                        @forelse($recentTransactions as $transaction)
                            <div class="flex gap-3">
                                <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-rose-50 text-rose-500">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z" />
                                    </svg>
                                </div>
                                <div class="min-w-0 flex-1">
                                    <p class="truncate text-sm font-medium text-wedding-ink">{{ $transaction->title }}</p>
                                    <p class="text-xs text-gray-400">
                                        {{ $transaction->vendor_name ?: $transaction->category_label }}
                                        @if($transaction->paid_at || $transaction->due_date)
                                            · {{ ($transaction->paid_at ?? $transaction->due_date)?->translatedFormat('d M Y') }}
                                        @endif
                                    </p>
                                </div>
                                <p class="shrink-0 text-sm font-semibold text-rose-600">-{{ $formatRupiah((float) $transaction->amount) }}</p>
                            </div>
                        @empty
                            <p class="text-sm text-gray-400">Belum ada transaksi terbaru.</p>
                        @endforelse
                    </div>
                    <a href="{{ $filterUrl(['tab' => 'transaksi']) }}" class="mt-4 flex h-10 w-full items-center justify-center rounded-xl border border-gray-200 text-sm font-medium text-gray-600 hover:bg-gray-50">
                        Lihat Semua Transaksi
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
