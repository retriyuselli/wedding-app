<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? config('app.name', 'Wedding App') }}</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen bg-wedding-bg font-sans text-wedding-ink antialiased">
    <div class="lg:flex lg:min-h-screen">
        <x-sidebar-nav />

        <div @class([
            'relative flex min-h-screen w-full min-w-0 flex-1 flex-col',
            'mx-auto max-w-md bg-white shadow-sm lg:mx-0 lg:max-w-none lg:bg-wedding-bg lg:shadow-none' => true,
        ])>
            @unless(request()->routeIs('dashboard', 'checklist', 'tamu', 'biaya', 'vendor', 'inspiration', 'messages', 'profil', 'dokumen'))
                <header class="sticky top-0 z-20 border-b border-gray-100 bg-white lg:border-sage-100 lg:bg-wedding-surface">
                    <div class="flex items-center justify-between px-4 py-3 lg:px-8">
                        <div>
                            <h1 class="text-lg font-semibold text-gray-800 lg:text-wedding-ink">@yield('heading', config('app.name'))</h1>
                            @hasSection('subheading')
                                <p class="text-xs text-gray-400 lg:text-sage-500">@yield('subheading')</p>
                            @endif
                        </div>
                        @hasSection('headerActions')
                            <div class="flex items-center gap-2">
                                @yield('headerActions')
                            </div>
                        @endif
                    </div>
                </header>
            @endunless

            <main @class([
                'flex-1 overflow-y-auto',
                'pb-24 lg:pb-8',
            ])>
                @yield('content')
            </main>

            <x-bottom-nav />
        </div>
    </div>
</body>
</html>
