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
                Merencanakan hari bahagiamu jadi lebih mudah
            </h1>
            <div class="mt-4 flex items-center gap-2 text-sage-600">
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>
            </div>
            <p class="mt-5 text-sm leading-relaxed text-sage-700/90">
                Kelola persiapan pernikahan, anggaran, tamu, vendor, dan banyak lagi dalam satu aplikasi.
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
            <h2 class="text-2xl font-semibold text-wedding-ink">Selamat Datang Kembali! 👋</h2>
            <p class="mt-1 text-sm text-gray-500">Masuk untuk melanjutkan perencanaan pernikahan Anda.</p>
        </div>

        <form method="POST" action="{{ route('login') }}" class="space-y-4">
            @csrf

            <div>
                <label for="email" class="mb-1.5 block text-sm font-medium text-gray-700">Email atau Nomor Telepon</label>
                <div class="relative">
                    <svg class="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
                    </svg>
                    <input
                        id="email"
                        name="email"
                        type="email"
                        value="{{ old('email') }}"
                        autocomplete="email"
                        placeholder="Masukkan email atau nomor telepon"
                        class="h-12 w-full rounded-xl border bg-white pl-10 pr-4 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 {{ $errors->has('email') ? 'border-red-400' : 'border-gray-200' }}"
                    >
                </div>
                @error('email')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label for="password" class="mb-1.5 block text-sm font-medium text-gray-700">Password</label>
                <div class="relative">
                    <svg class="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 0 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                    </svg>
                    <input
                        id="password"
                        name="password"
                        type="password"
                        autocomplete="current-password"
                        placeholder="Masukkan password"
                        class="h-12 w-full rounded-xl border bg-white pl-10 pr-11 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 {{ $errors->has('password') ? 'border-red-400' : 'border-gray-200' }}"
                    >
                    <button
                        type="button"
                        id="toggle-password"
                        class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                        aria-label="Tampilkan password"
                    >
                        <svg id="eye-open" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                        </svg>
                        <svg id="eye-closed" class="hidden h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                        </svg>
                    </button>
                </div>
                @error('password')
                    <p class="mt-1 text-xs text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex items-center justify-between gap-3">
                <label class="flex items-center gap-2 text-sm text-gray-600">
                    <input
                        id="remember"
                        name="remember"
                        type="checkbox"
                        @checked(old('remember'))
                        class="h-4 w-4 rounded border-gray-300 text-sage-600 focus:ring-sage-500"
                    >
                    Ingat saya
                </label>
                <a href="#" class="text-sm font-medium text-sage-700 hover:text-sage-800">Lupa password?</a>
            </div>

            <button
                type="submit"
                class="h-12 w-full rounded-xl bg-sage-700 text-sm font-semibold text-white transition hover:bg-sage-800 active:scale-[0.99]"
            >
                Masuk
            </button>
        </form>

        <div class="my-6 flex items-center gap-3">
            <div class="h-px flex-1 bg-gray-200"></div>
            <span class="text-xs text-gray-400">atau masuk dengan</span>
            <div class="h-px flex-1 bg-gray-200"></div>
        </div>

        <div class="grid grid-cols-2 gap-3">
            <button
                type="button"
                class="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white text-sm font-medium text-gray-700 transition hover:bg-gray-50"
            >
                <svg class="h-4 w-4" viewBox="0 0 24 24" aria-hidden="true">
                    <path fill="#EA4335" d="M12 10.2v3.9h5.5c-.24 1.3-1.7 3.8-5.5 3.8-3.3 0-6-2.7-6-6s2.7-6 6-6c1.9 0 3.2.8 3.9 1.5l2.7-2.6C17.5 3.2 15 2.2 12 2.2 6.8 2.2 2.5 6.5 2.5 11.7S6.8 21.2 12 21.2c6.9 0 8.6-4.8 8.6-7.2 0-.5 0-.9-.1-1.2H12z"/>
                </svg>
                Google
            </button>
            <button
                type="button"
                class="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white text-sm font-medium text-gray-700 transition hover:bg-gray-50"
            >
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    <path d="M16.365 1.43c0 1.14-.46 2.23-1.28 3.03-.84.82-2.04 1.28-3.27 1.22-.04-1.1.48-2.22 1.28-3.02.86-.84 2.1-1.3 3.27-1.23ZM20.8 17.13c-.57 1.3-.85 1.88-1.58 3.03-1.03 1.58-2.48 3.55-4.28 3.56-1.6.01-2.01-1.03-4.18-1.02-2.17.01-2.64 1.04-4.24 1.02-1.8-.01-3.17-1.72-4.2-3.3-2.88-4.4-3.18-9.56-1.4-12.3 1.27-1.95 3.28-3.1 5.18-3.1 1.93 0 3.14 1.03 4.74 1.03 1.53 0 2.46-1.03 4.66-1.03 1.67 0 3.44.9 4.7 2.46-4.13 2.24-3.46 8.07.6 9.65Z"/>
                </svg>
                Apple
            </button>
        </div>

        <p class="mt-6 text-center text-sm text-gray-500">
            Belum punya akun?
            <a href="{{ route('register') }}" class="font-semibold text-sage-700 hover:text-sage-800">Daftar sekarang</a>
        </p>
    </div>
@endsection

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const passwordInput = document.getElementById('password');
            const toggleButton = document.getElementById('toggle-password');
            const eyeOpen = document.getElementById('eye-open');
            const eyeClosed = document.getElementById('eye-closed');

            if (!passwordInput || !toggleButton || !eyeOpen || !eyeClosed) {
                return;
            }

            toggleButton.addEventListener('click', () => {
                const isHidden = passwordInput.type === 'password';
                passwordInput.type = isHidden ? 'text' : 'password';
                eyeOpen.classList.toggle('hidden', isHidden);
                eyeClosed.classList.toggle('hidden', !isHidden);
                toggleButton.setAttribute('aria-label', isHidden ? 'Sembunyikan password' : 'Tampilkan password');
            });
        });
    </script>
@endpush
