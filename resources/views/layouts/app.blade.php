<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? config('app.name', 'Wedding App') }}</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen bg-gray-50 font-sans antialiased">
    <div class="mx-auto max-w-md min-h-screen flex flex-col bg-white shadow-sm relative">

        {{-- Header --}}
        <header class="sticky top-0 z-20 bg-white border-b border-gray-100">
            <div class="flex items-center justify-between px-4 py-3">
                <div>
                    <h1 class="text-lg font-semibold text-gray-800">@yield('heading', config('app.name'))</h1>
                    @hasSection('subheading')
                        <p class="text-xs text-gray-400">@yield('subheading')</p>
                    @endif
                </div>
                @hasSection('headerActions')
                <div class="flex items-center gap-2">
                    @yield('headerActions')
                </div>
                @endif
            </div>
        </header>

        {{-- Main Content --}}
        <main class="flex-1 overflow-y-auto pb-24">
            @yield('content')
        </main>

        {{-- Bottom Navigation --}}
        <x-bottom-nav />
    </div>
</body>
</html>
