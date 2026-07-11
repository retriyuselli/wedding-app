@extends('layouts.auth')

@section('hero')
    <section class="auth-hero-panel relative hidden overflow-hidden lg:flex lg:w-[52%] lg:flex-col lg:justify-between lg:px-12 lg:py-10 xl:px-16">
        <div class="absolute -left-24 top-16 h-72 w-72 rounded-full bg-sage-200/50 blur-3xl"></div>
        <div class="absolute bottom-0 right-0 h-80 w-80 rounded-full bg-sage-300/30 blur-3xl"></div>

        <div class="relative z-10 flex items-center gap-3">
            <div class="flex h-11 w-11 items-center justify-center rounded-full bg-sage-100 text-sage-700">
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>
            </div>
            <span class="text-lg font-semibold tracking-tight text-sage-800">Wedding App</span>
        </div>

        <div class="relative z-10 my-8 max-w-lg">
            <h1 class="text-4xl font-semibold leading-tight text-sage-800 xl:text-[42px]">
                Mulai rencanakan pernikahan impianmu
            </h1>
            <p class="mt-5 text-sm leading-relaxed text-sage-700/90">
                Buat akun dan kelola checklist, tamu, anggaran, vendor, serta inspirasi dalam satu tempat.
            </p>
        </div>

        <div class="relative z-10 mt-auto">
            <img
                src="{{ asset('images/auth/login-hero.svg') }}"
                alt="Ilustrasi pasangan pernikahan"
                class="mx-auto w-full max-w-md object-contain"
            >
        </div>
    </section>
@endsection

@section('content')
    <div class="mb-6 flex items-center gap-3 lg:hidden">
        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-sage-100 text-sage-700">
            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
        </div>
        <span class="text-base font-semibold text-sage-800">Wedding App</span>
    </div>

    <div class="rounded-3xl border border-gray-100 bg-white p-6 shadow-[0_8px_30px_rgba(15,23,42,0.06)] sm:p-8">
        <div class="mb-6">
            <h2 class="text-2xl font-semibold text-wedding-ink">Buat Akun Baru</h2>
            <p class="mt-1 text-sm text-gray-500">Daftar untuk mulai merencanakan pernikahan Anda.</p>
        </div>

        <form method="POST" action="{{ route('register') }}" class="space-y-4">
            @csrf

            <div>
                <label for="name" class="mb-1.5 block text-sm font-medium text-gray-700">Nama Lengkap</label>
                <input
                    id="name"
                    name="name"
                    type="text"
                    value="{{ old('name') }}"
                    autocomplete="name"
                    placeholder="Nama Anda"
                    class="h-12 w-full rounded-xl border bg-white px-4 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 {{ $errors->has('name') ? 'border-red-400' : 'border-gray-200' }}"
                >
                @error('name')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label for="email" class="mb-1.5 block text-sm font-medium text-gray-700">Email</label>
                <input
                    id="email"
                    name="email"
                    type="email"
                    value="{{ old('email') }}"
                    autocomplete="email"
                    placeholder="email@contoh.com"
                    class="h-12 w-full rounded-xl border bg-white px-4 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 {{ $errors->has('email') ? 'border-red-400' : 'border-gray-200' }}"
                >
                @error('email')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label for="password" class="mb-1.5 block text-sm font-medium text-gray-700">Password</label>
                <input
                    id="password"
                    name="password"
                    type="password"
                    autocomplete="new-password"
                    placeholder="Minimal 8 karakter"
                    class="h-12 w-full rounded-xl border bg-white px-4 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 {{ $errors->has('password') ? 'border-red-400' : 'border-gray-200' }}"
                >
                @error('password')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label for="password_confirmation" class="mb-1.5 block text-sm font-medium text-gray-700">Konfirmasi Password</label>
                <input
                    id="password_confirmation"
                    name="password_confirmation"
                    type="password"
                    autocomplete="new-password"
                    placeholder="Ulangi password"
                    class="h-12 w-full rounded-xl border border-gray-200 bg-white px-4 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2"
                >
            </div>

            <button
                type="submit"
                class="h-12 w-full rounded-xl bg-sage-700 text-sm font-semibold text-white transition hover:bg-sage-800 active:scale-[0.99]"
            >
                Daftar
            </button>
        </form>

        <x-auth.social-login
            divider-text="atau daftar dengan"
            :google-enabled="$googleEnabled"
            :apple-enabled="$appleEnabled"
            :google-client-id="$googleClientId"
            :apple-client-id="$appleClientId"
            :apple-redirect-uri="$appleRedirectUri"
        />

        <p class="mt-6 text-center text-sm text-gray-500">
            Sudah punya akun?
            <a href="{{ route('login') }}" class="font-semibold text-sage-700 hover:text-sage-800">Masuk di sini</a>
        </p>
    </div>
@endsection
