@php
    $sidebarUnreadMessages = auth()->check()
        ? auth()->user()->messageThreads()
            ->whereHas('messages', fn ($query) => $query
                ->where('is_outgoing', false)
                ->whereNull('read_at'))
            ->count()
        : 0;

    $mainNav = [
        ['route' => 'dashboard', 'label' => 'Home', 'icon' => 'home', 'active' => request()->routeIs('dashboard'), 'badge' => null],
        ['route' => 'checklist', 'label' => 'Checklist', 'icon' => 'checklist', 'active' => request()->routeIs('checklist*'), 'badge' => null],
        ['route' => 'tamu', 'label' => 'Guest', 'icon' => 'guests', 'active' => request()->routeIs('tamu*'), 'badge' => null],
        ['route' => 'biaya', 'label' => 'Budget', 'icon' => 'budget', 'active' => request()->routeIs('biaya*') || request()->routeIs('uang-masuk*'), 'badge' => null],
        ['route' => 'vendor', 'label' => 'Vendor', 'icon' => 'vendor', 'active' => request()->routeIs('vendor*'), 'badge' => null],
        ['route' => 'inspiration', 'label' => 'Inspiration', 'icon' => 'inspiration', 'active' => request()->routeIs('inspiration*'), 'badge' => null],
        ['route' => 'messages', 'label' => 'Messages', 'icon' => 'messages', 'active' => request()->routeIs('messages*'), 'badge' => $sidebarUnreadMessages],
        ['route' => 'checklist', 'label' => 'Events', 'icon' => 'events', 'active' => false, 'badge' => null],
    ];

    $moreNav = [
        ['route' => 'profil', 'label' => 'Profil', 'active' => request()->routeIs('profil*')],
        ['route' => 'dokumen', 'label' => 'Dokumen', 'active' => request()->routeIs('dokumen*')],
        ['route' => 'privacy-policy', 'label' => 'Privasi & Keamanan', 'active' => request()->routeIs('privacy-policy')],
        ['route' => 'bantuan', 'label' => 'Bantuan & FAQ', 'active' => request()->routeIs('bantuan*')],
        ['route' => 'profil', 'label' => 'Settings', 'active' => false],
    ];
@endphp

<aside class="hidden lg:flex lg:w-[260px] lg:shrink-0 lg:flex-col lg:border-r lg:border-gray-100 lg:bg-white">
    <div class="flex h-[72px] items-center gap-3 px-6">
        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-sage-100 text-sage-700">
            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
        </div>
        <span class="text-[17px] font-semibold tracking-tight text-wedding-ink">Wedding App</span>
    </div>

    <nav class="flex-1 space-y-1 overflow-y-auto px-4 pb-4">
        @foreach ($mainNav as $item)
            <a href="{{ route($item['route']) }}"
               @class([
                   'flex items-center gap-3 rounded-xl px-3.5 py-2.5 text-[14px] font-medium transition-colors',
                   'bg-sage-100 text-sage-800' => $item['active'],
                   'text-gray-600 hover:bg-gray-50 hover:text-gray-900' => ! $item['active'],
               ])>
                @include('components.partials.sidebar-icon', ['icon' => $item['icon'], 'active' => $item['active']])
                <span class="flex-1">{{ $item['label'] }}</span>
                @if(($item['badge'] ?? 0) > 0)
                    <span class="flex h-5 min-w-5 items-center justify-center rounded-full bg-rose-500 px-1.5 text-[10px] font-semibold text-white">
                        {{ $item['badge'] > 9 ? '9+' : $item['badge'] }}
                    </span>
                @endif
            </a>
        @endforeach

        <details class="group mt-2" open>
            <summary class="flex cursor-pointer list-none items-center gap-3 rounded-xl px-3.5 py-2.5 text-[14px] font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900">
                <svg class="h-5 w-5 text-gray-500" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 12a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0ZM12.75 12a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0ZM18.75 12a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z" />
                </svg>
                <span class="flex-1">More</span>
                <svg class="h-4 w-4 text-gray-400 transition group-open:rotate-180" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                </svg>
            </summary>
            <div class="mt-1 space-y-0.5 pl-9">
                @foreach ($moreNav as $item)
                    <a href="{{ Route::has($item['route']) ? route($item['route']) : '#' }}"
                       @class([
                           'block rounded-lg px-3 py-2 text-[13px] hover:bg-gray-50 hover:text-gray-800',
                           'bg-sage-50 font-medium text-sage-800' => $item['active'] ?? false,
                           'text-gray-500' => ! ($item['active'] ?? false),
                       ])>
                        {{ $item['label'] }}
                    </a>
                @endforeach
            </div>
        </details>
    </nav>

    <div class="border-t border-gray-100 p-4">
        <div class="overflow-hidden rounded-2xl bg-sage-50">
            <x-dummy-image type="couple" alt="Pasangan" class="h-28 w-full object-cover" />
            <p class="px-4 py-3 text-[12px] leading-relaxed text-sage-800">
                Rencanakan hari bahagiamu bersama kami.
            </p>
        </div>
        <p class="mt-4 text-center text-[11px] text-gray-400">© {{ date('Y') }} Wedding App. All rights reserved.</p>
    </div>
</aside>
