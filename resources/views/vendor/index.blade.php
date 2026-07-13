@extends('layouts.app')

@section('content')
@php
    $filterUrl = fn (array $params = []): string => route('vendor', array_merge(
        request()->only(['category', 'q', 'location', 'sort', 'view', 'per_page']),
        $params,
    ));
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Vendor</h1>
                <p class="mt-1 text-sm text-gray-500">Temukan dan kelola semua vendor terbaik untuk pernikahan Anda</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <form method="GET" action="{{ route('vendor') }}" class="relative hidden sm:block">
                    @foreach(request()->only(['category', 'location', 'sort', 'view', 'per_page']) as $key => $value)
                        <input type="hidden" name="{{ $key }}" value="{{ $value }}">
                    @endforeach
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" name="q" value="{{ $search }}" placeholder="Cari vendor..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[280px]">
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
            {{-- Main content --}}
            <div class="space-y-4 lg:col-span-8">
                {{-- Category tabs --}}
                <div class="dashboard-scroll flex gap-2 overflow-x-auto pb-1">
                    @foreach($categoryTabs as $tab)
                        <a href="{{ $filterUrl(['category' => $tab['key']]) }}"
                           @class([
                               'shrink-0 rounded-full px-4 py-2 text-sm font-medium transition',
                               'bg-sage-600 text-white' => $activeCategory === $tab['key'],
                               'bg-white text-gray-600 ring-1 ring-gray-200 hover:bg-gray-50' => $activeCategory !== $tab['key'],
                           ])>
                            {{ $tab['label'] }}
                        </a>
                    @endforeach
                </div>

                <div class="dashboard-card overflow-hidden">
                    <div class="space-y-3 border-b border-gray-100 p-4">
                        <form method="GET" action="{{ route('vendor') }}" class="grid gap-2 lg:grid-cols-12">
                            <input type="hidden" name="category" value="{{ $activeCategory }}">
                            <input type="hidden" name="sort" value="{{ $activeSort }}">
                            <input type="hidden" name="view" value="{{ $activeView }}">
                            <input type="hidden" name="per_page" value="{{ $perPage }}">
                            <div class="lg:col-span-4">
                                <input type="search" name="q" value="{{ $search }}" placeholder="Cari vendor atau layanan..." class="h-10 w-full rounded-lg border border-gray-200 bg-white px-3 text-sm outline-none focus:ring-2 focus:ring-sage-300">
                            </div>
                            <div class="lg:col-span-3">
                                <select name="category" onchange="this.form.submit()" class="h-10 w-full rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-600">
                                    @foreach($categoryTabs as $tab)
                                        <option value="{{ $tab['key'] }}" @selected($activeCategory === $tab['key'])>{{ $tab['label'] }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="lg:col-span-3">
                                <select name="location" onchange="this.form.submit()" class="h-10 w-full rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-600">
                                    <option value="">Semua Lokasi</option>
                                    @foreach($locations as $city)
                                        <option value="{{ $city }}" @selected($activeLocation === $city)>{{ $city }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="flex gap-2 lg:col-span-2">
                                <button type="button" class="h-10 flex-1 rounded-lg border border-gray-200 bg-white text-sm text-gray-600 hover:bg-gray-50">Filter Lainnya</button>
                                <button type="submit" class="hidden">Cari</button>
                            </div>
                        </form>

                        <div class="flex flex-wrap items-center justify-between gap-2">
                            <p class="text-sm text-gray-500">
                                @if($vendors->total() > 0)
                                    Menampilkan {{ $vendors->firstItem() }}-{{ $vendors->lastItem() }} dari {{ $vendors->total() }} vendor
                                @else
                                    Tidak ada vendor ditemukan
                                @endif
                            </p>
                            <div class="flex items-center gap-2">
                                <select onchange="window.location.href='{{ $filterUrl(['sort' => '__SORT__']) }}'.replace('__SORT__', this.value)" class="rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-sm text-gray-600">
                                    <option value="terbaru" @selected($activeSort === 'terbaru')>Urutkan: Terbaru</option>
                                    <option value="nama" @selected($activeSort === 'nama')>Urutkan: Nama</option>
                                    <option value="rating" @selected($activeSort === 'rating')>Urutkan: Rating</option>
                                </select>
                                <a href="{{ $filterUrl(['view' => 'grid']) }}" @class(['rounded-lg p-2', 'bg-sage-100 text-sage-700' => $activeView === 'grid', 'text-gray-400 hover:bg-gray-100' => $activeView !== 'grid'])>
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 0 1 6 3.75h2.25A2.25 2.25 0 0 1 10.5 6v2.25a2.25 2.25 0 0 1-2.25 2.25H6a2.25 2.25 0 0 1-2.25-2.25V6ZM3.75 15.75A2.25 2.25 0 0 1 6 13.5h2.25a2.25 2.25 0 0 1 2.25 2.25V18a2.25 2.25 0 0 1-2.25 2.25H6A2.25 2.25 0 0 1 3.75 18v-2.25ZM13.5 6a2.25 2.25 0 0 1 2.25-2.25H18A2.25 2.25 0 0 1 20.25 6v2.25A2.25 2.25 0 0 1 18 10.5h-2.25a2.25 2.25 0 0 1-2.25-2.25V6ZM13.5 15.75a2.25 2.25 0 0 1 2.25-2.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-2.25A2.25 2.25 0 0 1 13.5 18v-2.25Z" /></svg>
                                </a>
                                <a href="{{ $filterUrl(['view' => 'list']) }}" @class(['rounded-lg p-2', 'bg-sage-100 text-sage-700' => $activeView === 'list', 'text-gray-400 hover:bg-gray-100' => $activeView !== 'list'])>
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75Zm.008 5.25h.007v.008H3.758v-.008Zm.008 5.25h.007v.008H3.75v-.008Z" /></svg>
                                </a>
                                <a href="{{ route('profil') }}" class="inline-flex items-center gap-1.5 rounded-lg bg-sage-600 px-4 py-2 text-sm font-medium text-white hover:bg-sage-700">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>
                                    Tambah Vendor
                                </a>
                            </div>
                        </div>
                    </div>

                    @if($activeView === 'list')
                        <div class="divide-y divide-gray-50">
                            @forelse($vendors as $vendor)
                                @include('vendor.partials.card-list', ['vendor' => $vendor, 'favoriteIds' => $favoriteIds])
                            @empty
                                <div class="p-10 text-center text-sm text-gray-400">Belum ada vendor untuk filter ini.</div>
                            @endforelse
                        </div>
                    @else
                        <div class="grid gap-4 p-4 sm:grid-cols-2">
                            @forelse($vendors as $vendor)
                                @include('vendor.partials.card-grid', ['vendor' => $vendor, 'favoriteIds' => $favoriteIds])
                            @empty
                                <div class="col-span-full p-10 text-center text-sm text-gray-400">Belum ada vendor untuk filter ini.</div>
                            @endforelse
                        </div>
                    @endif

                    @if($vendors->hasPages())
                        <div class="flex flex-col gap-3 border-t border-gray-100 px-4 py-3 text-sm text-gray-500 sm:flex-row sm:items-center sm:justify-between">
                            <div>{{ $vendors->links() }}</div>
                            <select onchange="window.location.href='{{ $filterUrl(['per_page' => '__PER__']) }}'.replace('__PER__', this.value)" class="rounded-lg border border-gray-200 bg-white px-2 py-1 text-xs">
                                @foreach([12, 24, 48] as $size)
                                    <option value="{{ $size }}" @selected($perPage === $size)>{{ $size }} / halaman</option>
                                @endforeach
                            </select>
                        </div>
                    @endif
                </div>
            </div>

            {{-- Right sidebar --}}
            <div class="space-y-4 lg:col-span-4">
                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Ringkasan Vendor</h3>
                    <div class="mt-4 grid grid-cols-2 gap-3 text-sm">
                        @foreach([
                            ['label' => 'Total Vendor', 'value' => $summary['total']],
                            ['label' => 'Vendor Aktif', 'value' => $summary['active']],
                            ['label' => 'Favorit Saya', 'value' => $summary['favorites']],
                            ['label' => 'Akan Dihubungi', 'value' => $summary['akan_dihubungi']],
                        ] as $item)
                            <div class="rounded-xl bg-gray-50 p-3">
                                <p class="text-xs text-gray-500">{{ $item['label'] }}</p>
                                <p class="mt-1 text-xl font-bold text-wedding-ink">{{ $item['value'] }}</p>
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Rating Rata-Rata</h3>
                    <div class="mt-3 flex items-center gap-2">
                        <span class="text-3xl font-bold text-wedding-ink">{{ number_format($averageRating, 1) }}</span>
                        <div class="flex text-amber-400">
                            @for($i = 1; $i <= 5; $i++)
                                <svg class="h-4 w-4 {{ $i <= round($averageRating) ? 'fill-current' : 'text-gray-200' }}" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 0 0 .95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 0 0-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 0 0-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 0 0-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 0 0 .951-.69l1.07-3.292Z"/></svg>
                            @endfor
                        </div>
                    </div>
                    <div class="mt-4 space-y-2">
                        @foreach($ratingDistribution as $row)
                            <div class="flex items-center gap-2 text-xs">
                                <span class="w-3 text-gray-500">{{ $row['stars'] }}</span>
                                <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-gray-100">
                                    <div class="h-full rounded-full bg-amber-400" style="width: {{ $row['percent'] }}%"></div>
                                </div>
                                <span class="w-8 text-right text-gray-400">{{ $row['percent'] }}%</span>
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-sm font-semibold text-wedding-ink">Vendor Favorit</h3>
                    <div class="mt-4 space-y-3">
                        @forelse($favoriteVendors as $favorite)
                            <div class="flex items-center gap-3">
                                <img src="{{ $favorite->coverImageUrl() }}" alt="{{ $favorite->name }}" class="h-10 w-10 rounded-lg object-cover">
                                <div class="min-w-0 flex-1">
                                    <p class="truncate text-sm font-medium text-wedding-ink">{{ $favorite->name }}</p>
                                    <p class="text-xs text-gray-400">{{ $favorite->displayCategoryName() }}</p>
                                </div>
                                <form method="POST" action="{{ route('vendor.favorite', $favorite->id) }}">
                                    @csrf
                                    <button type="submit" class="text-rose-500">
                                        <svg class="h-4 w-4 fill-current" viewBox="0 0 24 24"><path d="M11.645 20.91l-.007-.003-.022-.012a15.247 15.247 0 0 1-.383-.218 25.18 25.18 0 0 1-4.244-3.17C4.688 15.36 2.25 12.174 2.25 8.25 2.25 5.322 4.714 3 7.688 3A5.5 5.5 0 0 1 12 5.052 5.5 5.5 0 0 1 16.313 3c2.973 0 5.437 2.322 5.437 5.25 0 3.925-2.438 7.111-4.739 9.256a25.175 25.175 0 0 1-4.244 3.17 15.247 15.247 0 0 1-.383.219l-.022.012-.007.004-.003.001a.752.752 0 0 1-.704 0l-.003-.001Z"/></svg>
                                    </button>
                                </form>
                            </div>
                        @empty
                            <p class="text-sm text-gray-400">Belum ada vendor favorit. Klik ikon hati pada kartu vendor.</p>
                        @endforelse
                    </div>
                </div>

                <div class="dashboard-card overflow-hidden p-5">
                    <div class="flex items-start gap-3">
                        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-sage-100 text-sage-600">
                            <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                            </svg>
                        </div>
                        <div class="flex-1">
                            <h3 class="text-sm font-semibold text-wedding-ink">Belum menemukan vendor yang tepat?</h3>
                            <p class="mt-1 text-xs text-gray-500">Kirim permintaan dan tim kami akan membantu mencarikan vendor sesuai kebutuhanmu.</p>
                            <a href="{{ route('profil') }}" class="mt-3 inline-flex h-10 items-center justify-center rounded-xl bg-sage-600 px-4 text-sm font-medium text-white hover:bg-sage-700">
                                Kirim Permintaan Vendor
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
