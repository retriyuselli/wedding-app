@extends('layouts.app')

@section('heading', 'Daftar Tamu')

@section('content')
<div class="flex flex-col">

    {{-- Tabs --}}
    <div class="sticky top-[57px] z-10 bg-white border-b border-gray-100">
        <div class="flex px-4 pt-2">
            @foreach(['umum' => 'Tamu Umum', 'keluarga' => 'Keluarga', 'vip' => 'VIP'] as $key => $label)
            <a href="{{ route('tamu', ['tab' => $key]) }}"
               class="flex-1 pb-2 text-center text-sm font-medium border-b-2 transition
                      {{ $tab === $key ? 'border-rose-500 text-rose-600' : 'border-transparent text-gray-400 hover:text-gray-600' }}">
                {{ $label }}
            </a>
            @endforeach
        </div>
    </div>

    {{-- RSVP Summary --}}
    <div class="grid grid-cols-3 gap-2 bg-gray-50 px-4 py-3 border-b border-gray-100">
        <div class="rounded-xl bg-white p-2 text-center shadow-sm">
            <p class="text-lg font-bold text-emerald-500">{{ $rsvpSummary['hadir'] }}</p>
            <p class="text-xs text-gray-500">Hadir</p>
        </div>
        <div class="rounded-xl bg-white p-2 text-center shadow-sm">
            <p class="text-lg font-bold text-red-400">{{ $rsvpSummary['tidak_hadir'] }}</p>
            <p class="text-xs text-gray-500">Tidak Hadir</p>
        </div>
        <div class="rounded-xl bg-white p-2 text-center shadow-sm">
            <p class="text-lg font-bold text-amber-400">{{ $rsvpSummary['menunggu'] }}</p>
            <p class="text-xs text-gray-500">Menunggu</p>
        </div>
    </div>

    {{-- Search & Filter --}}
    <form method="GET" action="{{ route('tamu') }}" class="flex items-center gap-2 px-4 py-3 bg-white border-b border-gray-100">
        <input type="hidden" name="tab" value="{{ $tab }}">
        <div class="relative flex-1">
            <svg class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
            </svg>
            <input name="search" type="text" value="{{ $search }}" placeholder="Cari nama..."
                   class="w-full rounded-xl border border-gray-200 py-2 pl-9 pr-4 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <select name="rsvp" onchange="this.form.submit()"
                class="rounded-xl border border-gray-200 py-2 pl-3 pr-8 text-sm focus:border-rose-400 focus:outline-none">
            <option value="" {{ $rsvp === '' ? 'selected' : '' }}>Semua RSVP</option>
            <option value="hadir" {{ $rsvp === 'hadir' ? 'selected' : '' }}>Hadir</option>
            <option value="tidak_hadir" {{ $rsvp === 'tidak_hadir' ? 'selected' : '' }}>Tidak Hadir</option>
            <option value="menunggu" {{ $rsvp === 'menunggu' ? 'selected' : '' }}>Menunggu</option>
        </select>
        <button type="submit" class="rounded-xl bg-rose-100 px-3 py-2 text-xs font-medium text-rose-600 hover:bg-rose-200">
            Cari
        </button>
    </form>

    {{-- Flash --}}
    @if(session('success'))
    <div class="mx-4 mt-3 flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
        </svg>
        {{ session('success') }}
    </div>
    @endif

    {{-- Guest List --}}
    <div class="p-4 space-y-2">

        @php
            $list = match($tab) {
                'keluarga' => $family,
                'vip'      => $vipList,
                default    => $guests,
            };
        @endphp

        @forelse($list as $item)
        <div class="flex items-center gap-3 rounded-2xl border border-gray-100 bg-white px-4 py-3 shadow-sm">
            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-rose-100 font-semibold text-rose-600">
                {{ strtoupper(substr($item->name, 0, 1)) }}
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-800">{{ $item->name }}</p>
                <p class="text-xs text-gray-400">
                    @if($tab === 'keluarga' && $item->role) {{ $item->role }} · @endif
                    @if($tab === 'vip' && $item->jabatan) {{ $item->jabatan }}@if($item->instansi), {{ $item->instansi }}@endif · @endif
                    @if($tab === 'umum' && $item->table_number) Meja {{ $item->table_number }} · @endif
                    {{ $item->phone ?? '-' }}
                </p>
            </div>
            <div class="flex flex-col items-end gap-1">
                {{-- RSVP dropdown auto-submit --}}
                <form method="POST" action="{{ route('tamu.rsvp', [$tab, $item->id]) }}">
                    @csrf @method('PATCH')
                    <select name="rsvp_status" onchange="this.form.submit()"
                            class="rounded-lg border py-1 pl-2 pr-6 text-xs focus:outline-none
                                   {{ $item->rsvp_status === 'hadir' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' :
                                      ($item->rsvp_status === 'tidak_hadir' ? 'bg-red-50 text-red-600 border-red-200' : 'bg-amber-50 text-amber-700 border-amber-200') }}">
                        <option value="menunggu" {{ $item->rsvp_status === 'menunggu' ? 'selected' : '' }}>Menunggu</option>
                        <option value="hadir" {{ $item->rsvp_status === 'hadir' ? 'selected' : '' }}>Hadir</option>
                        <option value="tidak_hadir" {{ $item->rsvp_status === 'tidak_hadir' ? 'selected' : '' }}>Tidak Hadir</option>
                    </select>
                </form>
                <div class="flex gap-1">
                    <a href="{{ route('tamu.edit', [$tab, $item->id]) }}" class="text-gray-300 hover:text-gray-500 p-1">
                        <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
                        </svg>
                    </a>
                    <form method="POST" action="{{ route('tamu.destroy', [$tab, $item->id]) }}">
                        @csrf @method('DELETE')
                        <button type="submit" onclick="return confirm('Hapus tamu ini?')" class="text-gray-300 hover:text-red-400 p-1">
                            <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                            </svg>
                        </button>
                    </form>
                </div>
            </div>
        </div>
        @empty
        <div class="rounded-2xl border border-dashed border-gray-200 p-8 text-center">
            <p class="text-sm text-gray-400">Belum ada tamu di kategori ini.</p>
        </div>
        @endforelse

        <a href="{{ route('tamu.create', ['tab' => $tab]) }}"
           class="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-rose-200 py-4 text-sm font-medium text-rose-500 hover:bg-rose-50">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Tambah Tamu
        </a>
    </div>

</div>
@endsection
