@extends('layouts.guest')

@section('content')
<div class="rounded-2xl bg-white p-8 shadow-sm">
    <h2 class="mb-6 text-center text-xl font-semibold text-gray-800">Masuk ke Akun</h2>

    <form method="POST" action="{{ route('login') }}" class="space-y-4">
        @csrf
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
            <input name="password" type="password" autocomplete="current-password"
                   placeholder="••••••••"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none focus:ring-2 focus:ring-rose-100 {{ $errors->has('password') ? 'border-red-400' : 'border-gray-200' }}">
            @error('password')
                <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
            @enderror
        </div>

        <div class="flex items-center">
            <input name="remember" id="remember" type="checkbox"
                   class="h-4 w-4 rounded border-gray-300 text-rose-500 focus:ring-rose-400">
            <label for="remember" class="ml-2 text-sm text-gray-600">Ingat saya</label>
        </div>

        <button type="submit"
                class="w-full rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white transition hover:bg-rose-600 active:scale-95">
            Masuk
        </button>
    </form>

    <p class="mt-6 text-center text-sm text-gray-500">
        Belum punya akun?
        <a href="{{ route('register') }}" class="font-medium text-rose-500 hover:underline">Daftar sekarang</a>
    </p>
</div>
@endsection
