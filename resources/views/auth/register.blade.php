@extends('layouts.guest')

@section('content')
<div class="rounded-2xl bg-white p-8 shadow-sm">
    <h2 class="mb-6 text-center text-xl font-semibold text-gray-800">Buat Akun Baru</h2>

    <form method="POST" action="{{ route('register') }}" class="space-y-4">
        @csrf
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Lengkap</label>
            <input name="name" type="text" value="{{ old('name') }}" autocomplete="name"
                   placeholder="Nama Anda"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100 {{ $errors->has('name') ? 'border-red-400' : 'border-gray-200' }}">
            @error('name')
                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
            @enderror
        </div>

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Email</label>
            <input name="email" type="email" value="{{ old('email') }}" autocomplete="email"
                   placeholder="email@contoh.com"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100 {{ $errors->has('email') ? 'border-red-400' : 'border-gray-200' }}">
            @error('email')
                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
            @enderror
        </div>

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Password</label>
            <input name="password" type="password" autocomplete="new-password"
                   placeholder="Minimal 8 karakter"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100 {{ $errors->has('password') ? 'border-red-400' : 'border-gray-200' }}">
            @error('password')
                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
            @enderror
        </div>

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Konfirmasi Password</label>
            <input name="password_confirmation" type="password" autocomplete="new-password"
                   placeholder="Ulangi password"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100">
        </div>

        <button type="submit"
                class="w-full rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white transition hover:bg-rose-600 active:scale-95">
            Daftar
        </button>
    </form>

    <p class="mt-6 text-center text-sm text-gray-500">
        Sudah punya akun?
        <a href="{{ route('login') }}" class="font-medium text-rose-500 hover:underline">Masuk di sini</a>
    </p>
</div>
@endsection
