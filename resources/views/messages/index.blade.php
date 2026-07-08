@extends('layouts.app')

@section('content')
@php
    use App\Http\Controllers\MessageController;

    $filterUrl = fn (array $params = []): string => route('messages', array_merge(
        request()->only(['tab', 'q', 'thread']),
        $params,
    ));

    $projectLabel = $coupleLabel ? "Proyek: Pernikahan {$coupleLabel}" : 'Proyek Pernikahan';
    $projectDate = $akadEvent?->tgl_acara?->translatedFormat('d F Y');
    $projectLocation = $akadEvent?->lokasi_acara ?? $vendorProfile?->locationLabel();
    $isFavorite = $activeThread && in_array($activeThread->id, $favoriteIds, true);
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="messages-shell space-y-4 py-4 lg:space-y-5 lg:py-6">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="font-serif text-2xl font-semibold text-wedding-ink lg:text-[32px]">Messages</h1>
                <p class="mt-1 text-sm text-gray-500">Kelola percakapan dengan vendor dan tim pernikahan Anda</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <form method="GET" action="{{ route('messages') }}" class="relative hidden sm:block">
                    @foreach(request()->only(['tab', 'thread']) as $key => $value)
                        <input type="hidden" name="{{ $key }}" value="{{ $value }}">
                    @endforeach
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" name="q" value="{{ $search }}" placeholder="Cari pesan, vendor, atau percakapan..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[320px]">
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

        {{-- 3-column layout --}}
        <div class="grid gap-4 lg:grid-cols-12 lg:gap-5">
            {{-- Thread list --}}
            <div @class([
                'lg:col-span-3',
                'hidden lg:block' => $activeThread && ! request()->boolean('list'),
            ])>
                <div class="dashboard-card flex h-[calc(100vh-12rem)] flex-col overflow-hidden lg:min-h-[640px]">
                    <div class="space-y-3 border-b border-gray-100 p-4">
                        <form method="GET" action="{{ route('messages') }}" class="flex gap-2">
                            <input type="hidden" name="tab" value="{{ $tab }}">
                            <div class="relative flex-1">
                                <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                                </svg>
                                <input type="search" name="q" value="{{ $search }}" placeholder="Cari percakapan..." class="h-10 w-full rounded-lg border border-gray-200 bg-gray-50 pl-9 pr-3 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:bg-white focus:ring-2">
                            </div>
                            <button type="button" class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-gray-200 bg-white text-gray-500">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 6h9.75M10.5 6a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 6H7.5m3 12h9.75m-9.75 0a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m-3.75 0H7.5m9-6h3.75m-3.75 0a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m-9.75 0h9.75" />
                                </svg>
                            </button>
                        </form>

                        <div class="dashboard-scroll flex gap-1 overflow-x-auto pb-0.5">
                            @foreach([
                                ['key' => 'all', 'label' => 'Semua'],
                                ['key' => 'unread', 'label' => 'Belum Dibaca', 'badge' => $totalUnreadThreads],
                                ['key' => 'favorite', 'label' => 'Favorit'],
                            ] as $tabItem)
                                <a href="{{ $filterUrl(['tab' => $tabItem['key'], 'thread' => $activeThread?->id]) }}"
                                   @class([
                                       'inline-flex shrink-0 items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-medium transition',
                                       'bg-sage-700 text-white' => $tab === $tabItem['key'],
                                       'bg-gray-50 text-gray-600 ring-1 ring-gray-200 hover:bg-gray-100' => $tab !== $tabItem['key'],
                                   ])>
                                    {{ $tabItem['label'] }}
                                    @if(! empty($tabItem['badge']) && $tabItem['badge'] > 0)
                                        <span @class([
                                            'rounded-full px-1.5 py-0.5 text-[10px] font-semibold',
                                            'bg-white/20 text-white' => $tab === $tabItem['key'],
                                            'bg-sage-100 text-sage-700' => $tab !== $tabItem['key'],
                                        ])>{{ $tabItem['badge'] }}</span>
                                    @endif
                                </a>
                            @endforeach
                        </div>
                    </div>

                    <div class="flex-1 overflow-y-auto">
                        @forelse($threads as $thread)
                            @php
                                $isActive = $activeThread?->id === $thread->id;
                                $threadFavorite = in_array($thread->id, $favoriteIds, true);
                                $latestAt = $thread->latestMessage?->created_at ?? $thread->updated_at;
                            @endphp
                            <a href="{{ $filterUrl(['thread' => $thread->id]) }}"
                               @class([
                                   'flex items-start gap-3 border-b border-gray-50 px-4 py-3 transition hover:bg-gray-50',
                                   'bg-sage-50/70' => $isActive,
                               ])>
                                <img src="{{ $thread->avatarImageUrl() }}" alt="{{ $thread->name }}" class="h-11 w-11 shrink-0 rounded-full object-cover ring-1 ring-gray-100">
                                <div class="min-w-0 flex-1">
                                    <div class="flex items-center justify-between gap-2">
                                        <p class="truncate text-sm font-medium text-wedding-ink">{{ $thread->name }}</p>
                                        <span class="shrink-0 text-[11px] text-gray-400">{{ MessageController::formatThreadTime($latestAt) }}</span>
                                    </div>
                                    <p class="mt-0.5 truncate text-xs text-gray-500">{{ $thread->latestMessage?->body ?? 'Belum ada pesan' }}</p>
                                </div>
                                <div class="flex shrink-0 flex-col items-end gap-1 pt-0.5">
                                    @if($thread->unread_count > 0)
                                        <span class="flex h-5 min-w-5 items-center justify-center rounded-full bg-sage-600 px-1 text-[10px] font-semibold text-white">{{ $thread->unread_count }}</span>
                                    @elseif($threadFavorite)
                                        <svg class="h-4 w-4 text-amber-400" fill="currentColor" viewBox="0 0 24 24">
                                            <path d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z" />
                                        </svg>
                                    @endif
                                </div>
                            </a>
                        @empty
                            <div class="p-6 text-center text-sm text-gray-500">Belum ada percakapan.</div>
                        @endforelse
                    </div>

                    @if($threads->hasPages())
                        <div class="border-t border-gray-100 px-4 py-3">
                            <p class="mb-2 text-center text-[11px] text-gray-400">
                                Menampilkan {{ $threads->firstItem() }} - {{ $threads->lastItem() }} dari {{ $threads->total() }} percakapan
                            </p>
                            <div class="flex items-center justify-center gap-1">
                                @foreach($threads->getUrlRange(max(1, $threads->currentPage() - 1), min($threads->lastPage(), $threads->currentPage() + 1)) as $page => $url)
                                    <a href="{{ $url }}"
                                       @class([
                                           'flex h-8 w-8 items-center justify-center rounded-lg text-xs font-medium',
                                           'bg-sage-700 text-white' => $page === $threads->currentPage(),
                                           'text-gray-500 hover:bg-gray-50' => $page !== $threads->currentPage(),
                                       ])>{{ $page }}</a>
                                @endforeach
                            </div>
                        </div>
                    @endif
                </div>
            </div>

            {{-- Chat window --}}
            <div @class([
                'lg:col-span-5',
                'col-span-full',
                'hidden lg:block' => ! $activeThread,
            ])>
                @if($activeThread)
                    <div class="dashboard-card flex h-[calc(100vh-12rem)] flex-col overflow-hidden lg:min-h-[640px]">
                        {{-- Chat header --}}
                        <div class="flex items-center justify-between border-b border-gray-100 px-4 py-3">
                            <div class="flex items-center gap-3">
                                <a href="{{ route('messages', ['tab' => $tab, 'q' => $search, 'list' => 1]) }}" class="mr-1 text-gray-400 lg:hidden">
                                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
                                    </svg>
                                </a>
                                <img src="{{ $activeThread->avatarImageUrl() }}" alt="{{ $activeThread->name }}" class="h-10 w-10 rounded-full object-cover ring-1 ring-gray-100">
                                <div>
                                    <p class="text-sm font-semibold text-wedding-ink">{{ $activeThread->name }}</p>
                                    <p class="flex items-center gap-1.5 text-xs text-gray-500">
                                        @if($activeThread->is_online)
                                            <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
                                            Online
                                        @else
                                            Offline
                                        @endif
                                    </p>
                                </div>
                            </div>
                            <div class="flex items-center gap-1">
                                <form method="POST" action="{{ route('messages.favorite', $activeThread) }}">
                                    @csrf
                                    <input type="hidden" name="tab" value="{{ $tab }}">
                                    <input type="hidden" name="q" value="{{ $search }}">
                                    <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-50 hover:text-amber-400">
                                        <svg @class(['h-4 w-4', 'text-amber-400 fill-amber-400' => $isFavorite]) fill="{{ $isFavorite ? 'currentColor' : 'none' }}" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z" />
                                        </svg>
                                    </button>
                                </form>
                                <button type="button" class="hidden h-9 w-9 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-50 sm:flex">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z" />
                                    </svg>
                                </button>
                                <button type="button" class="hidden h-9 w-9 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-50 sm:flex">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m15.75 10.5 4.72-4.72a.75.75 0 0 1 1.28.53v11.38a.75.75 0 0 1-1.28.53l-4.72-4.72M4.5 18.75h9a2.25 2.25 0 0 0 2.25-2.25v-9a2.25 2.25 0 0 0-2.25-2.25h-9A2.25 2.25 0 0 0 2.25 7.5v9a2.25 2.25 0 0 0 2.25 2.25Z" />
                                    </svg>
                                </button>
                                <button type="button" class="flex h-9 w-9 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-50">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 6.75a.75.75 0 1 1 0-1.5.75.75 0 0 1 0 1.5ZM12 12.75a.75.75 0 1 1 0-1.5.75.75 0 0 1 0 1.5ZM12 18.75a.75.75 0 1 1 0-1.5.75.75 0 0 1 0 1.5Z" />
                                    </svg>
                                </button>
                            </div>
                        </div>

                        {{-- Project banner --}}
                        @if($activeThread->category === 'vendor')
                            <div class="mx-4 mt-3 rounded-xl bg-amber-50/80 p-3 ring-1 ring-amber-100">
                                <div class="flex items-start justify-between gap-3">
                                    <div class="min-w-0">
                                        <p class="text-xs font-medium text-amber-900">{{ $projectLabel }}</p>
                                        @if($projectDate)
                                            <p class="mt-0.5 text-[11px] text-amber-700/80">{{ $projectDate }}@if($projectLocation) · {{ $projectLocation }}@endif</p>
                                        @endif
                                    </div>
                                    <button type="button" class="shrink-0 rounded-lg bg-white px-2.5 py-1 text-[11px] font-medium text-amber-800 ring-1 ring-amber-200">Lihat Detail</button>
                                </div>
                            </div>
                        @endif

                        {{-- Messages --}}
                        <div class="flex-1 space-y-4 overflow-y-auto px-4 py-4">
                            @forelse($messagesByDate as $dateKey => $dayMessages)
                                @php $date = \Illuminate\Support\Carbon::parse($dateKey); @endphp
                                <div class="flex justify-center">
                                    <span class="rounded-full bg-gray-100 px-3 py-1 text-[11px] font-medium text-gray-500">{{ MessageController::formatDateSeparator($date) }}</span>
                                </div>

                                @foreach($dayMessages as $message)
                                    <div @class(['flex', 'justify-end' => $message->is_outgoing, 'justify-start' => ! $message->is_outgoing])>
                                        <div @class([
                                            'max-w-[85%] space-y-1',
                                            'items-end' => $message->is_outgoing,
                                        ])>
                                            <div @class([
                                                'rounded-2xl px-4 py-2.5 text-sm leading-relaxed',
                                                'rounded-br-md bg-sage-100 text-wedding-ink' => $message->is_outgoing,
                                                'rounded-bl-md bg-white text-wedding-ink ring-1 ring-gray-100' => ! $message->is_outgoing,
                                            ])>
                                                {{ $message->body }}
                                            </div>

                                            @if($activeThread->category === 'vendor' && ! $message->is_outgoing && $loop->iteration === 2)
                                                <div class="mt-2 flex items-center gap-3 rounded-xl bg-white p-3 ring-1 ring-gray-100">
                                                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-rose-50 text-rose-500">
                                                        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                                        </svg>
                                                    </div>
                                                    <div class="min-w-0 flex-1">
                                                        <p class="truncate text-xs font-medium text-wedding-ink">Proposal_{{ str_replace(' ', '_', $activeThread->name) }}.pdf</p>
                                                        <p class="text-[11px] text-gray-400">2.4 MB</p>
                                                    </div>
                                                    <button type="button" class="text-gray-400 hover:text-sage-600">
                                                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                            <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                                                        </svg>
                                                    </button>
                                                </div>
                                            @endif

                                            <div @class(['flex items-center gap-1 px-1', 'justify-end' => $message->is_outgoing])>
                                                <span class="text-[10px] text-gray-400">{{ MessageController::formatMessageTime($message->created_at) }}</span>
                                                @if($message->is_outgoing)
                                                    <svg class="h-3.5 w-3.5 text-sage-500" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                                    </svg>
                                                @endif
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            @empty
                                <div class="flex h-full items-center justify-center text-sm text-gray-400">Belum ada pesan dalam percakapan ini.</div>
                            @endforelse
                        </div>

                        {{-- Input --}}
                        <form method="POST" action="{{ route('messages.send', $activeThread) }}" class="border-t border-gray-100 p-4">
                            @csrf
                            <input type="hidden" name="tab" value="{{ $tab }}">
                            <input type="hidden" name="q" value="{{ $search }}">
                            <div class="flex items-end gap-2">
                                <button type="button" class="mb-1 flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-gray-400 hover:bg-gray-50">
                                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m18.375 12.739-7.693 7.693a4.5 4.5 0 0 1-6.364-6.364l10.94-10.94A3 3 0 1 1 19.5 7.372L8.432 18.44a4.5 4.5 0 0 0 6.364 6.364l7.693-7.693a.75.75 0 0 0-1.06-1.06Z" />
                                    </svg>
                                </button>
                                <div class="relative flex-1">
                                    <input type="text" name="body" required placeholder="Ketik pesan..." class="h-11 w-full rounded-full border border-gray-200 bg-gray-50 px-4 pr-10 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:bg-white focus:ring-2">
                                    <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400">
                                        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.182 15.182a4.5 4.5 0 0 1-6.364 0M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0ZM9.75 9.75c0 .414-.168.75-.375.75S9 10.164 9 9.75 9.168 9 9.75 9s.375.336.375.75Zm-.375 0h.008v.008h-.008V9.75Zm5.625 0c0 .414-.168.75-.375.75s-.375-.336-.375-.75.168-.75.375-.75.375.336.375.75Zm-.375 0h.008v.008h-.008V9.75Z" />
                                        </svg>
                                    </button>
                                </div>
                                <button type="submit" class="mb-0.5 flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-sage-700 text-white shadow-sm transition hover:bg-sage-800">
                                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5" />
                                    </svg>
                                </button>
                            </div>
                        </form>
                    </div>
                @else
                    <div class="dashboard-card hidden h-[calc(100vh-12rem)] items-center justify-center lg:flex lg:min-h-[640px]">
                        <div class="text-center">
                            <div class="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-sage-50 text-sage-600">
                                <svg class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M8.625 12a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H8.25m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H12m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 0 1-2.555-.337A5.972 5.972 0 0 1 5.41 20.97a5.969 5.969 0 0 1-.474-.065 4.48 4.48 0 0 0 .978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25Z" />
                                </svg>
                            </div>
                            <p class="text-sm font-medium text-wedding-ink">Pilih percakapan</p>
                            <p class="mt-1 text-xs text-gray-400">Pilih percakapan di sebelah kiri untuk mulai mengirim pesan</p>
                        </div>
                    </div>
                @endif
            </div>

            {{-- Vendor info sidebar --}}
            @if($activeThread)
                <div class="hidden lg:col-span-4 lg:block">
                    <div class="dashboard-card space-y-5 p-5">
                        <div>
                            <h2 class="text-sm font-semibold text-wedding-ink">Informasi Vendor</h2>
                            <div class="mt-4 flex items-center gap-3">
                                <img src="{{ $activeThread->avatarImageUrl() }}" alt="{{ $activeThread->name }}" class="h-12 w-12 rounded-full object-cover ring-1 ring-gray-100">
                                <div>
                                    <p class="text-sm font-medium text-wedding-ink">{{ $activeThread->name }}</p>
                                    <p class="flex items-center gap-1.5 text-xs text-gray-500">
                                        @if($activeThread->is_online)
                                            <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
                                            Online
                                        @else
                                            Offline
                                        @endif
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="grid grid-cols-3 gap-2">
                            <button type="button" class="rounded-lg border border-gray-200 py-2 text-[11px] font-medium text-gray-600 hover:bg-gray-50">Lihat Profil</button>
                            <button type="button" class="rounded-lg border border-gray-200 py-2 text-[11px] font-medium text-gray-600 hover:bg-gray-50">Telepon</button>
                            <button type="button" class="rounded-lg border border-gray-200 py-2 text-[11px] font-medium text-gray-600 hover:bg-gray-50">Kirim Email</button>
                        </div>

                        <div class="space-y-3 border-t border-gray-100 pt-4 text-sm">
                            <div class="flex items-start gap-3">
                                <svg class="mt-0.5 h-4 w-4 shrink-0 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M9.568 3H5.25A2.25 2.25 0 0 0 3 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 0 0 5.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 0 0 9.568 3Z" />
                                </svg>
                                <div>
                                    <p class="text-xs text-gray-400">Kategori</p>
                                    <p class="font-medium text-wedding-ink">{{ $vendorProfile?->category?->name ?? $activeThread->categoryLabel() }}</p>
                                </div>
                            </div>
                            <div class="flex items-start gap-3">
                                <svg class="mt-0.5 h-4 w-4 shrink-0 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z" />
                                </svg>
                                <div>
                                    <p class="text-xs text-gray-400">Lokasi</p>
                                    <p class="font-medium text-wedding-ink">{{ $vendorProfile?->locationLabel() ?? 'Indonesia' }}</p>
                                </div>
                            </div>
                            @if($vendorProfile?->phone)
                                <div class="flex items-start gap-3">
                                    <svg class="mt-0.5 h-4 w-4 shrink-0 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z" />
                                    </svg>
                                    <div>
                                        <p class="text-xs text-gray-400">Telepon</p>
                                        <p class="font-medium text-wedding-ink">{{ $vendorProfile->phone }}</p>
                                    </div>
                                </div>
                            @endif
                            @if($vendorProfile?->email)
                                <div class="flex items-start gap-3">
                                    <svg class="mt-0.5 h-4 w-4 shrink-0 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
                                    </svg>
                                    <div>
                                        <p class="text-xs text-gray-400">Email</p>
                                        <p class="font-medium text-wedding-ink">{{ $vendorProfile->email }}</p>
                                    </div>
                                </div>
                            @endif
                            <div class="flex items-start gap-3">
                                <svg class="mt-0.5 h-4 w-4 shrink-0 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                                </svg>
                                <div>
                                    <p class="text-xs text-gray-400">Jam Operasional</p>
                                    <p class="font-medium text-wedding-ink">09:00 - 18:00 WIB</p>
                                </div>
                            </div>
                        </div>

                        @if($activeThread->category === 'vendor')
                            <div class="rounded-xl bg-gray-50 p-3">
                                <p class="text-xs font-medium text-gray-500">Proyek Terkait</p>
                                <div class="mt-2 flex items-center gap-3">
                                    <x-dummy-image type="venue" :seed="$activeThread->id" class="h-12 w-12 rounded-lg object-cover" />
                                    <div class="min-w-0 flex-1">
                                        <p class="truncate text-sm font-medium text-wedding-ink">{{ $projectLabel }}</p>
                                        @if($projectDate)
                                            <p class="text-[11px] text-gray-400">{{ $projectDate }}</p>
                                        @endif
                                    </div>
                                    <span class="shrink-0 rounded-full bg-amber-50 px-2 py-0.5 text-[10px] font-medium text-amber-700">Dalam Proses</span>
                                </div>
                            </div>

                            @if($sharedAttachments->isNotEmpty())
                                <div>
                                    <h3 class="text-sm font-semibold text-wedding-ink">Lampiran Bersama</h3>
                                    <div class="mt-3 space-y-2">
                                        @foreach($sharedAttachments as $attachment)
                                            <div class="flex items-center gap-3 rounded-lg border border-gray-100 p-2.5">
                                                <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-rose-50 text-rose-500">
                                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                                    </svg>
                                                </div>
                                                <div class="min-w-0 flex-1">
                                                    <p class="truncate text-xs font-medium text-wedding-ink">{{ $attachment['name'] }}</p>
                                                    <p class="text-[11px] text-gray-400">{{ $attachment['size'] }}</p>
                                                </div>
                                                <button type="button" class="text-gray-400 hover:text-sage-600">
                                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                                                    </svg>
                                                </button>
                                            </div>
                                        @endforeach
                                    </div>
                                </div>
                            @endif

                            @if($notes->isNotEmpty())
                                <div>
                                    <h3 class="text-sm font-semibold text-wedding-ink">Catatan</h3>
                                    <div class="mt-3 space-y-3">
                                        @foreach($notes as $note)
                                            <div class="rounded-lg bg-gray-50 p-3">
                                                <p class="text-[11px] text-gray-400">{{ $note['date'] }} · {{ $note['author'] }}</p>
                                                <p class="mt-1 text-xs leading-relaxed text-gray-600">{{ $note['body'] }}</p>
                                            </div>
                                        @endforeach
                                    </div>
                                </div>
                            @endif
                        @endif
                    </div>
                </div>
            @endif
        </div>
    </div>
</div>
@endsection
