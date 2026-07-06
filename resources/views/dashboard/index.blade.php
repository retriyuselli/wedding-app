@extends('layouts.app')

@section('heading', 'Beranda')

@section('content')
<div class="space-y-4 p-4">

    {{-- Greeting Card --}}
    <div class="rounded-2xl bg-gradient-to-br from-rose-400 to-pink-500 p-5 text-white">
        @if($weddingInfo?->groom_name && $weddingInfo?->bride_name)
            <p class="text-sm font-medium opacity-80">Selamat datang,</p>
            <h2 class="mt-1 text-xl font-semibold">
                {{ $weddingInfo->groom_name }} &amp; {{ $weddingInfo->bride_name }}
            </h2>
        @else
            <p class="text-sm font-medium opacity-80">Selamat datang,</p>
            <h2 class="mt-1 text-xl font-semibold">{{ auth()->user()->name }}</h2>
            <a href="{{ route('profil') }}" class="mt-2 inline-block rounded-lg bg-white/20 px-3 py-1 text-xs font-medium hover:bg-white/30">
                Lengkapi profil →
            </a>
        @endif

        @if($nextEvent)
            <div class="mt-4 flex items-center gap-2 rounded-xl bg-white/20 px-3 py-2">
                <svg class="h-4 w-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                </svg>
                <div>
                    <p class="text-xs font-semibold">{{ $nextEvent->jenis_label }}</p>
                    <p class="text-xs opacity-80">{{ $nextEvent->tgl_acara->translatedFormat('d F Y') }}</p>
                </div>
                <div class="ml-auto text-right">
                    <p class="text-xs opacity-80">{{ $nextEvent->tgl_acara->diffForHumans() }}</p>
                </div>
            </div>
        @endif
    </div>

    {{-- Summary Cards --}}
    <div class="grid grid-cols-2 gap-3">
        <div class="rounded-2xl border border-gray-100 bg-white p-4 shadow-sm">
            <div class="mb-2 flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50">
                <svg class="h-5 w-5 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z" />
                </svg>
            </div>
            <p class="text-xs text-gray-400">Total Biaya</p>
            <p class="mt-0.5 text-sm font-semibold text-gray-800">Rp {{ number_format((float) $totalBudget, 0, ',', '.') }}</p>
            <p class="mt-1 text-xs text-emerald-600">Dibayar: Rp {{ number_format((float) $totalPaid, 0, ',', '.') }}</p>
        </div>

        <div class="rounded-2xl border border-gray-100 bg-white p-4 shadow-sm">
            <div class="mb-2 flex h-9 w-9 items-center justify-center rounded-xl bg-rose-50">
                <svg class="h-5 w-5 text-rose-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                </svg>
            </div>
            <p class="text-xs text-gray-400">Checklist</p>
            <p class="mt-0.5 text-sm font-semibold text-gray-800">{{ $doneTasks }}/{{ $totalTasks }} selesai</p>
            @if($totalTasks > 0)
                <div class="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-gray-100">
                    <div class="h-full rounded-full bg-rose-400" style="width: {{ round(($doneTasks / $totalTasks) * 100) }}%"></div>
                </div>
            @endif
        </div>
    </div>

    {{-- Events --}}
    @if($events->count() > 0)
    <div>
        <h3 class="mb-2 text-sm font-semibold text-gray-700">Acara Pernikahan</h3>
        <div class="space-y-2">
            @foreach($events as $event)
            <div class="flex items-center gap-3 rounded-xl border border-gray-100 bg-white px-4 py-3 shadow-sm">
                <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-rose-50">
                    <span class="text-lg">
                        @switch($event->jenis_acara)
                            @case('lamaran') 💍 @break
                            @case('pengajian') 📖 @break
                            @case('akad') 🕌 @break
                            @case('resepsi') 🎊 @break
                            @default 📅
                        @endswitch
                    </span>
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-800">{{ $event->jenis_label }}</p>
                    <p class="truncate text-xs text-gray-400">
                        {{ $event->tgl_acara ? $event->tgl_acara->translatedFormat('d F Y') : 'Tanggal belum diset' }}
                        @if($event->lokasi_acara) · {{ $event->lokasi_acara }} @endif
                    </p>
                </div>
                @if($event->tgl_acara?->isFuture())
                    <span class="shrink-0 rounded-lg bg-rose-50 px-2 py-1 text-xs font-medium text-rose-600">
                        {{ $event->tgl_acara->diffForHumans(short: true) }}
                    </span>
                @elseif($event->tgl_acara?->isPast())
                    <span class="shrink-0 rounded-lg bg-gray-100 px-2 py-1 text-xs text-gray-400">Selesai</span>
                @endif
            </div>
            @endforeach
        </div>
    </div>
    @else
    <div class="rounded-2xl border border-dashed border-gray-200 p-6 text-center">
        <p class="text-sm text-gray-400">Belum ada acara pernikahan.</p>
        <a href="{{ route('checklist') }}" class="mt-2 inline-block text-sm font-medium text-rose-500">Tambah Acara →</a>
    </div>
    @endif

</div>
@endsection
