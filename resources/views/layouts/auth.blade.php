<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? config('app.name', 'Wedding App') }}</title>
    @fonts
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen bg-[#f7f8f6] font-sans text-wedding-ink antialiased">
    <div class="flex min-h-screen flex-col">
        <div class="flex flex-1 flex-col lg:flex-row">
            @hasSection('hero')
                @yield('hero')
            @endif

            <div class="flex flex-1 items-center justify-center px-4 py-8 sm:px-6 lg:px-10 lg:py-12">
                <div class="w-full max-w-[420px]">
                    @yield('content')
                </div>
            </div>
        </div>

        <footer class="border-t border-gray-200/80 bg-white/80 backdrop-blur-sm">
            <div class="mx-auto flex max-w-6xl flex-col gap-4 px-4 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6 lg:px-8">
                <div class="grid grid-cols-2 gap-3 sm:flex sm:flex-wrap sm:items-center sm:gap-6">
                    <div class="flex items-center gap-2 text-[11px] text-gray-500">
                        <svg class="h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75m-3-7.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285Z" />
                        </svg>
                        <span>Privasi & Aman</span>
                    </div>
                    <div class="flex items-center gap-2 text-[11px] text-gray-500">
                        <svg class="h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.375 3.375 0 0 0-.995 2.684c0 .414.336.75.75.75h.75c.414 0 .75-.336.75-.75 0-.966.393-1.88 1.093-2.54 1.066-.98 1.75-2.39 1.75-3.94 0-2.9-2.35-5.25-5.25-5.25S6.75 7.1 6.75 10s2.35 5.25 5.25 5.25c.69 0 1.35-.133 1.95-.374" />
                        </svg>
                        <span>Aman & Terpercaya</span>
                    </div>
                    <div class="flex items-center gap-2 text-[11px] text-gray-500">
                        <svg class="h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15a4.5 4.5 0 0 0 4.5 4.5H18a3.75 3.75 0 0 0 1.332-7.257 3 3 0 0 0-3.758-3.848 5.25 5.25 0 0 0-10.233 2.33A4.502 4.502 0 0 0 2.25 15Z" />
                        </svg>
                        <span>Akses di Semua Perangkat</span>
                    </div>
                    <div class="flex items-center gap-2 text-[11px] text-gray-500">
                        <svg class="h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155" />
                        </svg>
                        <span>Bantuan 24/7</span>
                    </div>
                </div>
                <p class="text-center text-[11px] text-gray-400 sm:text-right">
                    &copy; {{ date('Y') }} Wedding App. All rights reserved.
                </p>
            </div>
        </footer>
    </div>

    @stack('scripts')
</body>
</html>
