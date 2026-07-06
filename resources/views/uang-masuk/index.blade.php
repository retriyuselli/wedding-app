@extends('layouts.app')

@section('heading', 'Uang Masuk')

@section('content')
<div class="flex flex-col">

    {{-- Summary --}}
    <div class="bg-white px-4 pt-4 pb-3 border-b border-gray-100 space-y-3">
        <div class="rounded-2xl bg-linear-to-br from-violet-400 to-purple-500 p-4 text-white">
            <p class="text-xs font-medium opacity-80">Total Uang Masuk</p>
            <p class="mt-0.5 text-2xl font-bold">Rp {{ number_format((float) $totalAll, 0, ',', '.') }}</p>
            <div class="mt-3 rounded-xl bg-white/20 px-3 py-2">
                <p class="text-xs opacity-80">Dikonfirmasi</p>
                <p class="text-sm font-semibold">Rp {{ number_format((float) $totalConfirmed, 0, ',', '.') }}</p>
            </div>
        </div>

        {{-- Filter --}}
        <div class="flex gap-1 overflow-x-auto">
            @foreach(['' => 'Semua', 'menunggu' => 'Menunggu', 'confirmed' => 'Dikonfirmasi', 'rejected' => 'Ditolak'] as $key => $label)
            <a href="{{ route('uang-masuk', $key ? ['status' => $key] : []) }}"
               class="shrink-0 rounded-full px-3 py-1.5 text-xs font-medium transition
                      {{ request('status', '') === $key ? 'bg-violet-500 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">
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

        @forelse($payments as $payment)
        <div class="rounded-2xl border border-gray-100 bg-white p-4 shadow-sm">
            <div class="flex items-start justify-between gap-2">
                <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 flex-wrap">
                        <p class="text-sm font-semibold text-gray-800">{{ $payment->sender_name }}</p>
                        <span class="rounded-full px-2 py-0.5 text-xs font-medium
                            {{ $payment->status === 'confirmed' ? 'bg-emerald-100 text-emerald-700' :
                               ($payment->status === 'rejected'  ? 'bg-red-100 text-red-600'     : 'bg-amber-100 text-amber-700') }}">
                            {{ $payment->status_label }}
                        </span>
                    </div>
                    <p class="mt-0.5 text-xs text-gray-400">
                        {{ $payment->transfer_date->translatedFormat('d F Y') }}
                        @if($payment->bank_name) · {{ $payment->bank_name }} @endif
                    </p>
                    @if($payment->description)
                        <p class="mt-1 text-xs text-gray-500">{{ $payment->description }}</p>
                    @endif
                    <p class="mt-2 text-base font-bold text-gray-900">
                        Rp {{ number_format((float) $payment->amount, 0, ',', '.') }}
                    </p>
                    @if($payment->reference_number)
                        <p class="mt-0.5 text-xs text-gray-400">Ref: {{ $payment->reference_number }}</p>
                    @endif
                </div>
                <div class="flex flex-col items-end gap-2">
                    <a href="{{ route('uang-masuk.edit', $payment->id) }}" class="text-gray-300 hover:text-gray-500">
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                        </svg>
                    </a>
                    <form method="POST" action="{{ route('uang-masuk.destroy', $payment->id) }}">
                        @csrf @method('DELETE')
                        <button type="submit" onclick="return confirm('Hapus data ini?')" class="text-gray-300 hover:text-red-400">
                            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                            </svg>
                        </button>
                    </form>
                </div>
            </div>
        </div>
        @empty
        <div class="rounded-2xl border border-dashed border-gray-200 p-8 text-center">
            <p class="text-sm text-gray-400">Belum ada data uang masuk.</p>
        </div>
        @endforelse

        <a href="{{ route('uang-masuk.create') }}"
           class="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-violet-200 py-4 text-sm font-medium text-violet-500 hover:bg-violet-50">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Tambah Uang Masuk
        </a>
    </div>

</div>
@endsection
