@extends('layouts.app')

@section('heading', 'Profil')

@section('content')
<div class="p-4 space-y-4">

    {{-- Avatar --}}
    <div class="flex flex-col items-center py-4">
        <div class="flex h-20 w-20 items-center justify-center rounded-full bg-rose-100 text-3xl font-bold text-rose-500">
            {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
        </div>
        <p class="mt-2 text-base font-semibold text-gray-800">{{ auth()->user()->name }}</p>
        <p class="text-sm text-gray-400">{{ auth()->user()->email }}</p>
    </div>

    {{-- Info Akun --}}
    <div class="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-50">
            <h3 class="text-sm font-semibold text-gray-700">Informasi Akun</h3>
        </div>
        <form method="POST" action="{{ route('profil.update') }}" class="p-4 space-y-4">
            @csrf @method('PUT')

            @if(session('success_profile'))
            <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
                {{ session('success_profile') }}
            </div>
            @endif

            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Nama Lengkap</label>
                <input name="name" type="text" value="{{ old('name', $user->name) }}"
                       class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100 {{ $errors->has('name') ? 'border-red-400' : 'border-gray-200' }}">
                @error('name') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Email</label>
                <input name="email" type="email" value="{{ old('email', $user->email) }}"
                       class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100 {{ $errors->has('email') ? 'border-red-400' : 'border-gray-200' }}">
                @error('email') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">WhatsApp</label>
                <input name="whatsapp" type="tel" value="{{ old('whatsapp', $user->whatsapp) }}" placeholder="08xx"
                       class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100">
            </div>
            <button type="submit"
                    class="w-full rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan Perubahan
            </button>
        </form>
    </div>

    {{-- Info Pernikahan --}}
    <div class="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-50">
            <h3 class="text-sm font-semibold text-gray-700">Info Pernikahan</h3>
        </div>
        <form method="POST" action="{{ route('profil.wedding') }}" class="p-4 space-y-4">
            @csrf @method('PUT')

            @if(session('success_wedding'))
            <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
                {{ session('success_wedding') }}
            </div>
            @endif

            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Nama Pengantin Pria</label>
                <input name="groom_name" type="text" value="{{ old('groom_name', $info?->groom_name) }}"
                       placeholder="Nama lengkap"
                       class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100">
            </div>
            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Nama Pengantin Wanita</label>
                <input name="bride_name" type="text" value="{{ old('bride_name', $info?->bride_name) }}"
                       placeholder="Nama lengkap"
                       class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100">
            </div>
            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Budaya / Adat</label>
                <input name="budaya" type="text" value="{{ old('budaya', $info?->budaya) }}"
                       placeholder="Misal: Jawa, Sunda, Minang"
                       class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100">
            </div>
            <button type="submit"
                    class="w-full rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan Info Pernikahan
            </button>
        </form>
    </div>

    {{-- Ubah Password --}}
    <div class="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-50">
            <h3 class="text-sm font-semibold text-gray-700">Keamanan</h3>
        </div>
        <form method="POST" action="{{ route('profil.password') }}" class="p-4 space-y-4">
            @csrf @method('PUT')

            @if(session('success_password'))
            <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
                {{ session('success_password') }}
            </div>
            @endif

            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Password Saat Ini</label>
                <input name="current_password" type="password"
                       class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('current_password') ? 'border-red-400' : 'border-gray-200' }}">
                @error('current_password') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Password Baru</label>
                <input name="new_password" type="password"
                       class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('new_password') ? 'border-red-400' : 'border-gray-200' }}">
                @error('new_password') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="mb-1 block text-sm font-medium text-gray-700">Konfirmasi Password Baru</label>
                <input name="new_password_confirmation" type="password"
                       class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
            </div>
            <button type="submit"
                    class="w-full rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Ubah Password
            </button>
        </form>
    </div>

    {{-- Logout --}}
    <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button type="submit"
                class="flex w-full items-center justify-center gap-2 rounded-2xl border border-red-200 py-3 text-sm font-medium text-red-500 hover:bg-red-50">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15m-3 0-3-3m0 0 3-3m-3 3H15" />
            </svg>
            Keluar
        </button>
    </form>

</div>
@endsection
