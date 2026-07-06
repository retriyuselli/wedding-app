@extends('layouts.app')

@section('heading', 'Laporan Biaya')

@section('content')
<div class="flex flex-col">

    {{-- Budget Card --}}
    <div class="bg-white px-4 pt-4 pb-2 space-y-3 border-b border-gray-100">
        <div class="rounded-2xl bg-linear-to-br from-emerald-400 to-teal-500 p-4 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-xs font-medium opacity-80">Total Budget</p>
                    <p class="mt-0.5 text-xl font-bold">Rp {{ number_format((float) $totalBudget, 0, ',', '.') }}</p>
                </div>
                <a href="{{ route('biaya.budget') }}" class="rounded-xl bg-white/20 p-2 hover:bg-white/30">
                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                    </svg>
                </a>
            </div>
            <div class="mt-3 grid grid-cols-2 gap-2">
                <div class="rounded-xl bg-white/20 p-2">
                    <p class="text-xs opacity-80">Sudah Dibayar</p>
                    <p class="text-sm font-semibold">Rp {{ number_format((float) $totalPaid, 0, ',', '.') }}</p>
                </div>
                <div class="rounded-xl bg-white/20 p-2">
                    <p class="text-xs opacity-80">Belum Dibayar</p>
                    <p class="text-sm font-semibold">Rp {{ number_format((float) $totalPending, 0, ',', '.') }}</p>
                </div>
            </div>
            @if($totalBudget > 0)
            <div class="mt-3">
                <div class="h-1.5 w-full overflow-hidden rounded-full bg-white/30">
                    <div class="h-full rounded-full bg-white" style="width: {{ min(round(($totalPaid / $totalBudget) * 100), 100) }}%"></div>
                </div>
                <p class="mt-1 text-xs opacity-80">{{ round(($totalPaid / $totalBudget) * 100) }}% dari budget terpakai</p>
            </div>
            @endif
        </div>

        {{-- Filter Tabs --}}
        <div class="flex gap-1 overflow-x-auto">
            @foreach(['semua' => 'Semua', 'belum' => 'Belum Bayar', 'sudah' => 'Sudah Bayar', 'overdue' => 'Overdue'] as $key => $label)
            <a href="{{ route('biaya', ['filter' => $key]) }}"
               class="shrink-0 rounded-full px-3 py-1.5 text-xs font-medium transition
                      {{ $filter === $key ? ($key === 'overdue' ? 'bg-red-500 text-white' : 'bg-rose-500 text-white') : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">
                {{ $label }}
            </a>
            @endforeach
        </div>
    </div>

    {{-- Flash --}}
    @if(session('success'))
    <div class="mx-4 mt-3 flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
        </svg>
        {{ session('success') }}
    </div>
    @endif

    {{-- List --}}
    <div class="p-4 space-y-3">

        @forelse($schedules as $schedule)
        <div class="rounded-2xl border border-gray-100 bg-white p-4 shadow-sm">
            <div class="flex items-start justify-between gap-2">
                <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 flex-wrap">
                        <p class="text-sm font-semibold text-gray-800">{{ $schedule->title }}</p>
                        <span class="rounded-full px-2 py-0.5 text-xs font-medium
                            {{ $schedule->status === 'paid' ? 'bg-emerald-100 text-emerald-700' :
                               ($schedule->status === 'overdue' ? 'bg-red-100 text-red-600' : 'bg-amber-100 text-amber-700') }}">
                            {{ $schedule->status === 'paid' ? 'Lunas' : ($schedule->status === 'overdue' ? 'Overdue' : 'Belum Bayar') }}
                        </span>
                    </div>
                    @if($schedule->vendor_name)
                        <p class="mt-0.5 text-xs text-gray-400">{{ $schedule->vendor_name }}</p>
                    @endif
                    <div class="mt-2 flex items-center gap-3">
                        <span class="text-sm font-bold text-gray-900">
                            Rp {{ number_format((float) $schedule->amount, 0, ',', '.') }}
                        </span>
                        @if($schedule->due_date)
                        <span class="text-xs {{ $schedule->status !== 'paid' && $schedule->due_date->isPast() ? 'text-red-400' : 'text-gray-400' }}">
                            Jatuh tempo: {{ $schedule->due_date->translatedFormat('d M Y') }}
                        </span>
                        @endif
                    </div>
                    <div class="mt-1">
                        <span class="inline-block rounded-lg bg-gray-100 px-2 py-0.5 text-xs text-gray-500">
                            {{ $schedule->category_label }}
                        </span>
                    </div>
                </div>
                <div class="flex flex-col items-end gap-2">
                    <a href="{{ route('biaya.edit', $schedule->id) }}" class="text-gray-300 hover:text-gray-500">
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                        </svg>
                    </a>
                    @if($schedule->status !== 'paid')
                    <form method="POST" action="{{ route('biaya.markPaid', $schedule->id) }}">
                        @csrf @method('PATCH')
                        <button type="submit" class="rounded-lg bg-emerald-50 px-2 py-1 text-xs font-medium text-emerald-600 hover:bg-emerald-100">
                            Lunas
                        </button>
                    </form>
                    @endif
                </div>
            </div>
        </div>
        @empty
        <div class="rounded-2xl border border-dashed border-gray-200 p-8 text-center">
            <p class="text-sm text-gray-400">Belum ada jadwal pembayaran.</p>
        </div>
        @endforelse

        <a href="{{ route('biaya.create') }}"
           class="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-rose-200 py-4 text-sm font-medium text-rose-500 hover:bg-rose-50">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Tambah Jadwal Bayar
        </a>
    </div>

</div>
@endsection
