@extends('layouts.app')

@section('content')
@php
    $filterUrl = fn (array $params = []): string => route('inspiration', array_merge(
        request()->only(['category', 'theme', 'color', 'q', 'sort', 'view', 'per_page']),
        $params,
    ));
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="font-serif text-2xl font-semibold text-wedding-ink lg:text-[32px]">Inspiration</h1>
                <p class="mt-1 text-sm text-gray-500">Temukan ide dan inspirasi untuk mewujudkan pernikahan impian Anda</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <form method="GET" action="{{ route('inspiration') }}" class="relative hidden sm:block">
                    @foreach(request()->only(['category', 'theme', 'color', 'sort', 'view', 'per_page']) as $key => $value)
                        <input type="hidden" name="{{ $key }}" value="{{ $value }}">
                    @endforeach
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" name="q" value="{{ $search }}" placeholder="Cari inspirasi..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[300px]">
                    <span class="pointer-events-none absolute right-3 top-1/2 hidden -translate-y-1/2 rounded-md border border-gray-200 bg-gray-50 px-1.5 py-0.5 text-[10px] font-medium text-gray-400 lg:inline">⌘K</span>
                </form>

                <button type="button" class="relative hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
                    </svg>
                    @if($unreadNotifications > 0)
                        <span class="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-semibold text-white">{{ min($unreadNotifications, 9) }}</span>
                    @endif
                </button>

                <a href="{{ route('profil') }}" class="flex items-center gap-2 rounded-xl border border-gray-200 bg-white py-1.5 pl-1.5 pr-3">
                    <x-dummy-image type="avatar" :alt="$coupleLabel" class="h-9 w-9 rounded-full object-cover" />
                    <div class="hidden min-w-0 sm:block">
                        <p class="max-w-[120px] truncate text-sm font-medium text-wedding-ink">{{ $coupleLabel }}</p>
                        @if($weddingDateLabel)
                            <p class="text-[11px] text-gray-400">{{ $weddingDateLabel }}</p>
                        @endif
                    </div>
                </a>
            </div>
        </div>

        <div class="grid gap-5 lg:grid-cols-12 lg:gap-6">
            <div class="space-y-4 lg:col-span-8">
                {{-- Category tabs --}}
                <div class="dashboard-scroll flex gap-2 overflow-x-auto pb-1">
                    @foreach($categoryTabs as $tab)
                        <a href="{{ $filterUrl(['category' => $tab['key']]) }}"
                           @class([
                               'inline-flex shrink-0 items-center gap-1.5 rounded-full px-4 py-2 text-sm font-medium transition',
                               'bg-sage-700 text-white' => $activeCategory === $tab['key'],
                               'bg-white text-gray-600 ring-1 ring-gray-200 hover:bg-gray-50' => $activeCategory !== $tab['key'],
                           ])>
                            {{ $tab['label'] }}
                        </a>
                    @endforeach
                </div>

                <div class="dashboard-card overflow-hidden">
                    <div class="space-y-3 border-b border-gray-100 p-4">
                        <form method="GET" action="{{ route('inspiration') }}" class="flex flex-col gap-3 lg:flex-row lg:items-center">
                            <input type="hidden" name="category" value="{{ $activeCategory }}">
                            <input type="hidden" name="sort" value="{{ $activeSort }}">
                            <input type="hidden" name="view" value="{{ $activeView }}">
                            <input type="hidden" name="per_page" value="{{ $perPage }}">

                            <select name="theme" onchange="this.form.submit()" class="h-10 rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-600 lg:w-40">
                                @foreach($themeOptions as $key => $label)
                                    <option value="{{ $key }}" @selected($activeTheme === (string) $key)>{{ $label }}</option>
                                @endforeach
                            </select>

                            <div class="flex items-center gap-2">
                                @foreach($themeColors as $swatch)
                                    <a href="{{ $filterUrl(['color' => $swatch['key']]) }}"
                                       class="h-7 w-7 rounded-full ring-2 ring-offset-1 {{ $activeColor === $swatch['key'] ? 'ring-sage-500' : 'ring-transparent' }}"
                                       style="background-color: {{ $swatch['color'] }}"
                                       title="{{ $swatch['label'] }}"></a>
                                @endforeach
                            </div>

                            <button type="button" class="h-10 rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-600 hover:bg-gray-50">Filter Lainnya</button>

                            <div class="ml-auto flex items-center gap-2">
                                <select onchange="window.location.href='{{ $filterUrl(['sort' => '__SORT__']) }}'.replace('__SORT__', this.value)" class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-600">
                                    <option value="terbaru" @selected($activeSort === 'terbaru')>Terbaru</option>
                                    <option value="populer" @selected($activeSort === 'populer')>Populer</option>
                                    <option value="nama" @selected($activeSort === 'nama')>Nama</option>
                                </select>
                                <a href="{{ $filterUrl(['view' => 'grid']) }}" @class(['rounded-lg p-2', 'bg-sage-100 text-sage-700' => $activeView === 'grid', 'text-gray-400 hover:bg-gray-100' => $activeView !== 'grid'])>
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 0 1 6 3.75h2.25A2.25 2.25 0 0 1 10.5 6v2.25a2.25 2.25 0 0 1-2.25 2.25H6a2.25 2.25 0 0 1-2.25-2.25V6ZM3.75 15.75A2.25 2.25 0 0 1 6 13.5h2.25a2.25 2.25 0 0 1 2.25 2.25V18a2.25 2.25 0 0 1-2.25 2.25H6A2.25 2.25 0 0 1 3.75 18v-2.25ZM13.5 6a2.25 2.25 0 0 1 2.25-2.25H18A2.25 2.25 0 0 1 20.25 6v2.25A2.25 2.25 0 0 1 18 10.5h-2.25a2.25 2.25 0 0 1-2.25-2.25V6ZM13.5 15.75a2.25 2.25 0 0 1 2.25-2.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-2.25A2.25 2.25 0 0 1 13.5 18v-2.25Z" /></svg>
                                </a>
                                <a href="{{ $filterUrl(['view' => 'list']) }}" @class(['rounded-lg p-2', 'bg-sage-100 text-sage-700' => $activeView === 'list', 'text-gray-400 hover:bg-gray-100' => $activeView !== 'list'])>
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75Zm.008 5.25h.007v.008H3.758v-.008Zm.008 5.25h.007v.008H3.75v-.008Z" /></svg>
                                </a>
                            </div>
                        </form>
                    </div>

                    <div class="flex items-center justify-between border-b border-gray-100 px-4 py-3">
                        <h2 class="text-sm font-semibold text-wedding-ink">Rekomendasi Untukmu</h2>
                        <a href="{{ $filterUrl(['sort' => 'populer']) }}" class="text-xs font-medium text-sage-600 hover:text-sage-700">Lihat Semua</a>
                    </div>

                    @if($activeView === 'list')
                        <div class="divide-y divide-gray-50">
                            @forelse($inspirations as $inspiration)
                                @include('inspiration.partials.card-list', ['inspiration' => $inspiration, 'savedIds' => $savedIds])
                            @empty
                                <div class="p-10 text-center text-sm text-gray-400">Belum ada inspirasi untuk filter ini.</div>
                            @endforelse
                        </div>
                    @else
                        <div class="grid gap-4 p-4 sm:grid-cols-2 xl:grid-cols-3">
                            @forelse($inspirations as $inspiration)
                                @include('inspiration.partials.card-grid', ['inspiration' => $inspiration, 'savedIds' => $savedIds])
                            @empty
                                <div class="col-span-full p-10 text-center text-sm text-gray-400">Belum ada inspirasi untuk filter ini.</div>
                            @endforelse
                        </div>
                    @endif

                    @if($inspirations->hasPages())
                        <div class="flex flex-col gap-3 border-t border-gray-100 px-4 py-3 text-sm text-gray-500 sm:flex-row sm:items-center sm:justify-between">
                            <p>Menampilkan {{ $inspirations->firstItem() }}-{{ $inspirations->lastItem() }} dari {{ $inspirations->total() }} inspirasi</p>
                            <div class="flex items-center gap-3">
                                {{ $inspirations->links() }}
                                <select onchange="window.location.href='{{ $filterUrl(['per_page' => '__PER__']) }}'.replace('__PER__', this.value)" class="rounded-lg border border-gray-200 bg-white px-2 py-1 text-xs">
                                    @foreach([8, 12, 24] as $size)
                                        <option value="{{ $size }}" @selected($perPage === $size)>{{ $size }} / halaman</option>
                                    @endforeach
                                </select>
                            </div>
                        </div>
                    @endif

                    <div class="border-t border-gray-100 p-4">
                        @if($inspirations->hasMorePages())
                            <a href="{{ $inspirations->nextPageUrl() }}" class="flex h-11 w-full items-center justify-center gap-2 rounded-xl bg-sage-50 text-sm font-medium text-sage-700 hover:bg-sage-100">
                                Muat Lebih Banyak Inspirasi
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" /></svg>
                            </a>
                        @else
                            <button type="button" class="flex h-11 w-full items-center justify-center gap-2 rounded-xl bg-sage-50 text-sm font-medium text-sage-700">
                                Muat Lebih Banyak Inspirasi
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" /></svg>
                            </button>
                        @endif
                    </div>
                </div>
            </div>

            {{-- Right sidebar --}}
            <div class="space-y-4 lg:col-span-4">
                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Tren Populer</h3>
                    <div class="mt-4 space-y-3">
                        @foreach($popularTrends as $trend)
                            <div class="flex items-center gap-3">
                                <img src="{{ $trend->coverImageUrl() }}" alt="{{ $trend->title }}" class="h-10 w-10 rounded-lg object-cover">
                                <div class="min-w-0 flex-1">
                                    <p class="truncate text-sm font-medium text-wedding-ink">{{ $trend->title }}</p>
                                    <p class="text-xs text-gray-400">{{ $trend->categoryLabel() }}</p>
                                </div>
                                <span class="inline-flex items-center gap-1 text-xs font-medium text-amber-600">
                                    <svg class="h-3.5 w-3.5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M12.963 2.286a.75.75 0 0 0-1.071-.136 9.742 9.742 0 0 0-3.539 6.176 7.547 7.547 0 0 1-1.705-1.715.75.75 0 0 0-1.152-.082A9 9 0 1 0 15.68 4.534a7.46 7.46 0 0 1-2.717-2.248ZM15.75 10.5a.75.75 0 0 1-.75.75h-6a.75.75 0 0 1 0-1.5h6a.75.75 0 0 1 .75.75Z" clip-rule="evenodd"/></svg>
                                    {{ $trend->likes_count }}
                                </span>
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Mood Favorit</h3>
                    <div class="mt-4 grid grid-cols-2 gap-2">
                        @foreach($moods as $mood)
                            <div class="flex items-center justify-between rounded-xl px-3 py-2.5 {{ $mood['bg'] }}">
                                <span class="text-xs font-medium {{ $mood['text'] }}">{{ $mood['label'] }}</span>
                                <span class="rounded-full bg-white/80 px-1.5 py-0.5 text-[10px] font-semibold text-gray-600">{{ $moodCounts[$mood['key']] ?? 0 }}</span>
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Koleksi Saya</h3>
                    <div class="mt-4 space-y-3">
                        @foreach($collections as $collection)
                            <div class="flex items-center gap-3">
                                <img src="{{ $collection['cover'] }}" alt="{{ $collection['label'] }}" class="h-10 w-10 rounded-lg object-cover">
                                <div class="min-w-0 flex-1">
                                    <p class="truncate text-sm font-medium text-wedding-ink">{{ $collection['label'] }}</p>
                                    <p class="text-xs text-gray-400">{{ $collection['count'] }} item</p>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card overflow-hidden p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Butuh ide yang lebih spesifik?</h3>
                    <p class="mt-1 text-xs text-gray-500">Konsultasikan tema pernikahanmu dengan tim kami.</p>
                    <a href="{{ route('profil') }}" class="mt-4 inline-flex h-10 w-full items-center justify-center rounded-xl bg-sage-700 text-sm font-medium text-white hover:bg-sage-800">
                        Konsultasi Sekarang
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
