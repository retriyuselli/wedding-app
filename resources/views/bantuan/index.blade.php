@extends('layouts.app')

@section('content')
<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Bantuan & FAQ</h1>
                <p class="mt-1 text-sm text-gray-500">Temukan jawaban cepat atau hubungi kami jika membutuhkan bantuan.</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <form method="GET" action="{{ route('bantuan') }}" class="relative hidden sm:block">
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" name="q" value="{{ $search }}" placeholder="Cari bantuan atau pertanyaan..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-4 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[300px]">
                </form>

                <button type="button" class="relative hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
                    </svg>
                    @if($unreadNotifications > 0)
                        <span class="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-semibold text-white">{{ min($unreadNotifications, 9) }}</span>
                    @endif
                </button>

                <button type="button" class="hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
                    </svg>
                </button>

                <button type="button" class="hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                    </svg>
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
            {{-- Main column --}}
            <div class="space-y-5 lg:col-span-8 lg:space-y-6">
                {{-- FAQ --}}
                <div class="dashboard-card overflow-hidden">
                    <div class="flex items-center justify-between gap-3 border-b border-gray-100 px-5 py-4">
                        <h2 class="text-[15px] font-semibold text-wedding-ink">Pertanyaan yang Sering Diajukan</h2>
                        <a href="{{ route('bantuan') }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Semua FAQ →</a>
                    </div>

                    <div class="divide-y divide-gray-100">
                        @forelse($faqs as $faq)
                            <details id="faq-{{ $faq['id'] }}" class="group">
                                <summary class="flex cursor-pointer list-none items-center gap-4 px-5 py-4 hover:bg-gray-50/60">
                                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-sage-50 text-sage-700">
                                        @include('components.partials.help-icon', ['icon' => $faq['icon']])
                                    </div>
                                    <span class="min-w-0 flex-1 text-sm font-medium text-wedding-ink">{{ $faq['question'] }}</span>
                                    <svg class="h-4 w-4 shrink-0 text-gray-400 transition group-open:rotate-90" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                                    </svg>
                                </summary>
                                <div class="border-t border-gray-50 bg-gray-50/40 px-5 py-4 pl-[4.75rem] text-sm leading-relaxed text-gray-600">
                                    {{ $faq['answer'] }}
                                </div>
                            </details>
                        @empty
                            <div class="px-5 py-10 text-center text-sm text-gray-500">
                                Tidak ada FAQ yang cocok dengan pencarian Anda.
                            </div>
                        @endforelse
                    </div>
                </div>

                {{-- Help topics --}}
                <div>
                    <h2 class="mb-4 text-[15px] font-semibold text-wedding-ink">Topik Bantuan</h2>
                    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
                        @foreach($topics as $topic)
                            <div class="dashboard-card flex flex-col p-5">
                                <div @class(['mb-4 flex h-11 w-11 items-center justify-center rounded-xl', $topic['icon_bg'], $topic['icon_text']])>
                                    @include('components.partials.help-icon', ['icon' => $topic['icon'], 'class' => 'h-5 w-5'])
                                </div>
                                <h3 class="text-sm font-semibold text-wedding-ink">{{ $topic['title'] }}</h3>
                                <p class="mt-2 flex-1 text-xs leading-relaxed text-gray-500">{{ $topic['description'] }}</p>
                                <a href="{{ Route::has($topic['route']) ? route($topic['route']) : '#' }}"
                                   class="mt-4 inline-flex items-center gap-1 text-xs font-medium text-sage-600 hover:text-sage-800">
                                    Lihat Artikel
                                    <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" />
                                    </svg>
                                </a>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>

            {{-- Right sidebar --}}
            <div class="space-y-4 lg:col-span-4">
                <div class="dashboard-card overflow-hidden">
                    <div class="border-b border-gray-100 px-5 py-4">
                        <h3 class="text-[15px] font-semibold text-wedding-ink">Hubungi Kami</h3>
                    </div>
                    <div class="divide-y divide-gray-100">
                        @foreach($contactMethods as $method)
                            <div class="flex items-center gap-3 px-5 py-4">
                                <div class="min-w-0 flex-1">
                                    <p class="text-sm font-medium text-wedding-ink">{{ $method['title'] }}</p>
                                    <p class="mt-0.5 text-xs text-gray-500">{{ $method['subtitle'] }}</p>
                                </div>
                                @if($method['external'])
                                    <a href="{{ $method['href'] }}" target="_blank" rel="noopener"
                                       class="shrink-0 rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-xs font-medium text-sage-700 hover:bg-sage-50">
                                        {{ $method['action'] }}
                                    </a>
                                @else
                                    <button type="button"
                                            class="shrink-0 rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-xs font-medium text-sage-700 hover:bg-sage-50">
                                        {{ $method['action'] }}
                                    </button>
                                @endif
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card p-5">
                    <div class="mb-4 flex items-center justify-between">
                        <h3 class="text-[15px] font-semibold text-wedding-ink">Panduan Populer</h3>
                    </div>
                    <div class="space-y-1">
                        @foreach($popularGuides as $guide)
                            <a href="{{ route($guide['route']) }}"
                               class="flex items-center gap-3 rounded-xl px-2 py-2.5 text-sm text-gray-600 hover:bg-gray-50 hover:text-gray-900">
                                <svg class="h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                </svg>
                                <span class="min-w-0 flex-1">{{ $guide['title'] }}</span>
                            </a>
                        @endforeach
                    </div>
                    <a href="{{ route('bantuan') }}" class="mt-4 inline-flex items-center gap-1 text-xs font-medium text-sage-600 hover:text-sage-800">
                        Lihat Semua Panduan →
                    </a>
                </div>

                <div class="dashboard-card p-5">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Informasi Aplikasi</h3>
                    <dl class="mt-4 space-y-3 text-sm">
                        <div class="flex items-center justify-between gap-3">
                            <dt class="text-gray-500">Versi Aplikasi</dt>
                            <dd class="font-medium text-wedding-ink">{{ $appVersion }}</dd>
                        </div>
                        <div class="flex items-center justify-between gap-3">
                            <dt class="text-gray-500">Update Terakhir</dt>
                            <dd class="font-medium text-wedding-ink">{{ $lastUpdatedLabel }}</dd>
                        </div>
                        <div class="flex items-center justify-between gap-3">
                            <dt class="text-gray-500">Syarat & Ketentuan</dt>
                            <dd>
                                <a href="{{ route('terms') }}" target="_blank" rel="noopener" class="font-medium text-sage-600 hover:text-sage-800">Lihat</a>
                            </dd>
                        </div>
                        <div class="flex items-center justify-between gap-3">
                            <dt class="text-gray-500">Kebijakan Privasi</dt>
                            <dd>
                                <a href="{{ route('privacy-policy') }}" target="_blank" rel="noopener" class="font-medium text-sage-600 hover:text-sage-800">Lihat</a>
                            </dd>
                        </div>
                    </dl>
                </div>

                <div class="dashboard-card overflow-hidden bg-gradient-to-br from-sage-50 to-white p-6 text-center">
                    <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-white shadow-sm">
                        <svg class="h-8 w-8 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
                        </svg>
                    </div>
                    <h3 class="mt-4 text-base font-semibold text-wedding-ink">Masih butuh bantuan?</h3>
                    <p class="mt-2 text-sm leading-relaxed text-gray-500">Tim kami akan dengan senang hati membantu Anda.</p>
                    <a href="mailto:{{ $supportEmail }}"
                       class="mt-5 inline-flex h-11 w-full items-center justify-center rounded-xl bg-sage-700 text-sm font-medium text-white hover:bg-sage-800">
                        Hubungi Kami
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
