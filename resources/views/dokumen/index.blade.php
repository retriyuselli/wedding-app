@extends('layouts.app')

@section('content')
@php
    use App\Http\Controllers\DokumenController;
    use App\Support\DocumentFolder;

    $filterUrl = fn (array $params = []): string => route('dokumen', array_merge(
        request()->only(['folder', 'sort', 'per_page', 'q']),
        $params,
    ));

    $folderDefinitions = DocumentFolder::definitions();
    $selectableFolders = DocumentFolder::selectableFolders();
@endphp

<div class="bg-wedding-bg lg:min-h-screen">
    <div class="dashboard-shell space-y-5 py-4 lg:space-y-6 lg:py-8">
        {{-- Header --}}
        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="min-w-0">
                <h1 class="text-2xl font-semibold text-wedding-ink lg:text-[28px]">Dokumen Pernikahan</h1>
                <p class="mt-1 text-sm text-gray-500">Simpan dan kelola semua dokumen penting pernikahan Anda di sini.</p>
            </div>

            <div class="flex flex-wrap items-center gap-2 lg:gap-3">
                <form method="GET" action="{{ route('dokumen') }}" class="relative hidden sm:block">
                    @foreach(request()->only(['folder', 'sort', 'per_page']) as $key => $value)
                        <input type="hidden" name="{{ $key }}" value="{{ $value }}">
                    @endforeach
                    <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                    <input type="search" name="q" value="{{ $search }}" placeholder="Cari dokumen..." class="h-11 w-full rounded-xl border border-gray-200 bg-white pl-10 pr-14 text-sm text-gray-700 outline-none ring-sage-300 placeholder:text-gray-400 focus:ring-2 sm:w-[280px]">
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

                <button type="button" class="hidden h-11 w-11 items-center justify-center rounded-xl border border-gray-200 bg-white text-gray-500 lg:flex">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
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
            {{-- Main content --}}
            <div class="space-y-5 lg:col-span-8 lg:space-y-6">
                {{-- Folder Saya --}}
                <div>
                    <div class="mb-4 flex items-center justify-between gap-3">
                        <h2 class="text-[15px] font-semibold text-wedding-ink">Folder Saya</h2>
                        <button type="button" class="inline-flex items-center gap-1.5 text-xs font-medium text-sage-600 hover:text-sage-800">
                            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z" />
                                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                            </svg>
                            Kelola Folder
                        </button>
                    </div>

                    <div class="flex gap-3 overflow-x-auto pb-1">
                        @php
                            $allDefinition = $folderDefinitions[DocumentFolder::All];
                            $allActive = $folder === DocumentFolder::All;
                        @endphp
                        <a href="{{ $filterUrl(['folder' => DocumentFolder::All, 'page' => null]) }}"
                           @class([
                               'dashboard-card min-w-[148px] shrink-0 p-4 transition',
                               'border-sage-300 ring-2 ring-sage-100' => $allActive,
                               'hover:border-sage-200' => ! $allActive,
                           ])>
                            <div @class(['mb-3 flex h-10 w-10 items-center justify-center rounded-xl', $allDefinition['icon_bg']])>
                                <svg @class(['h-5 w-5', $allDefinition['icon_text']]) fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M3 7a2 2 0 0 1 2-2h5l2 2h9a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7Z"/>
                                </svg>
                            </div>
                            <p class="text-sm font-medium text-wedding-ink">{{ $allDefinition['label'] }}</p>
                            <p class="mt-1 text-xs text-gray-500">{{ $folderCounts[DocumentFolder::All] ?? 0 }} Files</p>
                        </a>

                        @foreach($selectableFolders as $folderKey)
                            @if($folderKey === DocumentFolder::All)
                                @continue
                            @endif
                            @php
                                $definition = $folderDefinitions[$folderKey];
                                $isActive = $folder === $folderKey;
                            @endphp
                            <a href="{{ $filterUrl(['folder' => $folderKey, 'page' => null]) }}"
                               @class([
                                   'dashboard-card min-w-[148px] shrink-0 p-4 transition',
                                   'border-sage-300 ring-2 ring-sage-100' => $isActive,
                                   'hover:border-sage-200' => ! $isActive,
                               ])>
                                <div @class(['mb-3 flex h-10 w-10 items-center justify-center rounded-xl', $definition['icon_bg']])>
                                    <svg @class(['h-5 w-5', $definition['icon_text']]) fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M3 7a2 2 0 0 1 2-2h5l2 2h9a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7Z"/>
                                    </svg>
                                </div>
                                <p class="text-sm font-medium text-wedding-ink">{{ $definition['label'] }}</p>
                                <p class="mt-1 text-xs text-gray-500">{{ $folderCounts[$folderKey] ?? 0 }} Files</p>
                            </a>
                        @endforeach

                        <button type="button" class="dashboard-card flex min-w-[148px] shrink-0 flex-col items-center justify-center border-dashed p-4 text-center hover:border-sage-300">
                            <div class="mb-3 flex h-10 w-10 items-center justify-center rounded-xl border border-dashed border-gray-300 text-gray-400">
                                <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                                </svg>
                            </div>
                            <p class="text-sm font-medium text-gray-600">Buat Folder Baru</p>
                        </button>
                    </div>
                </div>

                {{-- Document table --}}
                <div class="dashboard-card overflow-hidden">
                    <div class="flex flex-col gap-3 border-b border-gray-100 px-4 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-5">
                        <div>
                            <h2 class="text-[15px] font-semibold text-wedding-ink">
                                {{ $folder === DocumentFolder::All ? 'Semua Dokumen' : DocumentFolder::label($folder) }}
                            </h2>
                            <p class="mt-0.5 text-xs text-gray-500">{{ $documents->total() }} dokumen tersimpan</p>
                        </div>

                        <div class="flex flex-wrap items-center gap-2">
                            <button type="button" class="inline-flex h-10 items-center gap-2 rounded-xl border border-gray-200 bg-white px-3 text-xs font-medium text-gray-600">
                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 6h9.75M10.5 6a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 0 1-3 0M3.75 6H7.5m0 0a1.5 1.5 0 0 1 3 0m-3 0a1.5 1.5 0 0 0 3 0m-3 7.5h9.75M10.5 13.5a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 0 1-3 0M3.75 13.5H7.5m0 0a1.5 1.5 0 0 1 3 0m-3 0a1.5 1.5 0 0 0 3 0" />
                                </svg>
                                Filter
                            </button>

                            <div class="relative">
                                <label for="sort" class="sr-only">Urutkan</label>
                                <select id="sort" onchange="window.location.href='{{ $filterUrl(['sort' => '__SORT__', 'page' => null]) }}'.replace('__SORT__', this.value)"
                                        class="h-10 appearance-none rounded-xl border border-gray-200 bg-white py-2 pl-3 pr-8 text-xs font-medium text-gray-600 outline-none ring-sage-300 focus:ring-2">
                                    <option value="latest" @selected($sort === 'latest')>Terbaru</option>
                                    <option value="oldest" @selected($sort === 'oldest')>Terlama</option>
                                    <option value="name" @selected($sort === 'name')>Nama A-Z</option>
                                </select>
                                <svg class="pointer-events-none absolute right-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                                </svg>
                            </div>

                            <div class="hidden items-center rounded-xl border border-gray-200 bg-white p-1 sm:flex">
                                <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-sage-100 text-sage-700">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75Zm0 5.25h.007v.008H3.75v-.008Zm0 5.25h.007v.008H3.75v-.008Z" />
                                    </svg>
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="hidden overflow-x-auto lg:block">
                        <table class="min-w-full text-left text-sm">
                            <thead class="border-b border-gray-100 bg-gray-50/60 text-xs font-medium text-gray-500">
                                <tr>
                                    <th class="px-5 py-3">Nama Dokumen</th>
                                    <th class="px-5 py-3">Folder</th>
                                    <th class="px-5 py-3">Diupload Oleh</th>
                                    <th class="px-5 py-3">Tanggal</th>
                                    <th class="px-5 py-3">Ukuran</th>
                                    <th class="px-5 py-3 text-right">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                @forelse($documents as $document)
                                    @php
                                        $badge = DokumenController::fileBadge($document['file_name'], $document['mime_type']);
                                        $folderBadge = DocumentFolder::badgeClasses($document['folder']);
                                    @endphp
                                    <tr class="hover:bg-gray-50/60">
                                        <td class="px-5 py-4">
                                            <div class="flex items-start gap-3">
                                                <div @class(['flex h-10 w-10 shrink-0 flex-col items-center justify-center rounded-xl', $badge['bg']])>
                                                    <span @class(['text-[9px] font-bold leading-none', $badge['color']])>{{ $badge['label'] }}</span>
                                                </div>
                                                <div class="min-w-0">
                                                    <p class="truncate font-medium text-wedding-ink">{{ $document['file_name'] }}</p>
                                                    <p class="mt-0.5 line-clamp-1 text-xs text-gray-500">{{ $document['description'] }}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="px-5 py-4">
                                            <span @class(['inline-flex rounded-lg px-2.5 py-1 text-xs font-medium', $folderBadge['badge_bg'], $folderBadge['badge_text']])>
                                                {{ DocumentFolder::label($document['folder']) }}
                                            </span>
                                        </td>
                                        <td class="px-5 py-4 text-gray-600">{{ $document['uploaded_by'] }}</td>
                                        <td class="px-5 py-4 text-gray-600">
                                            <div>{{ $document['uploaded_at']->translatedFormat('d M Y') }}</div>
                                            <div class="text-xs text-gray-400">{{ $document['uploaded_at']->format('H:i') }}</div>
                                        </td>
                                        <td class="px-5 py-4 text-gray-600">{{ DokumenController::formatFileSize($document['file_size']) }}</td>
                                        <td class="px-5 py-4 text-right">
                                            @if($document['url'])
                                                <a href="{{ $document['url'] }}" target="_blank" rel="noopener" class="inline-flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-600">
                                                    <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                                                        <path d="M12 6.75a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM12 10.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM12 14.25a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Z"/>
                                                    </svg>
                                                </a>
                                            @else
                                                <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-600">
                                                    <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                                                        <path d="M12 6.75a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM12 10.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM12 14.25a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Z"/>
                                                    </svg>
                                                </button>
                                            @endif
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="6" class="px-5 py-12 text-center text-sm text-gray-500">
                                            Tidak ada dokumen yang cocok dengan pencarian atau folder ini.
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>

                    {{-- Mobile list --}}
                    <div class="divide-y divide-gray-100 lg:hidden">
                        @forelse($documents as $document)
                            @php
                                $badge = DokumenController::fileBadge($document['file_name'], $document['mime_type']);
                                $folderBadge = DocumentFolder::badgeClasses($document['folder']);
                            @endphp
                            <div class="p-4">
                                <div class="flex items-start gap-3">
                                    <div @class(['flex h-10 w-10 shrink-0 flex-col items-center justify-center rounded-xl', $badge['bg']])>
                                        <span @class(['text-[9px] font-bold leading-none', $badge['color']])>{{ $badge['label'] }}</span>
                                    </div>
                                    <div class="min-w-0 flex-1">
                                        <p class="font-medium text-wedding-ink">{{ $document['file_name'] }}</p>
                                        <p class="mt-0.5 text-xs text-gray-500">{{ $document['description'] }}</p>
                                        <div class="mt-2 flex flex-wrap items-center gap-2 text-[11px] text-gray-500">
                                            <span @class(['inline-flex rounded-md px-2 py-0.5 font-medium', $folderBadge['badge_bg'], $folderBadge['badge_text']])>
                                                {{ DocumentFolder::label($document['folder']) }}
                                            </span>
                                            <span>{{ $document['uploaded_by'] }}</span>
                                            <span>{{ $document['uploaded_at']->translatedFormat('d M Y') }}</span>
                                            <span>{{ DokumenController::formatFileSize($document['file_size']) }}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        @empty
                            <div class="p-8 text-center text-sm text-gray-500">
                                Tidak ada dokumen yang cocok dengan pencarian atau folder ini.
                            </div>
                        @endforelse
                    </div>

                    @if($documents->hasPages())
                        <div class="flex flex-col gap-3 border-t border-gray-100 px-4 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-5">
                            <p class="text-xs text-gray-500">
                                Menampilkan {{ $documents->firstItem() }} - {{ $documents->lastItem() }} dari {{ $documents->total() }} dokumen
                            </p>

                            <div class="flex flex-wrap items-center gap-3">
                                <div class="flex items-center gap-1">
                                    @if($documents->onFirstPage())
                                        <span class="flex h-8 w-8 items-center justify-center rounded-lg text-gray-300">‹</span>
                                    @else
                                        <a href="{{ $documents->previousPageUrl() }}" class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-600 hover:bg-gray-50">‹</a>
                                    @endif

                                    @foreach($documents->getUrlRange(max(1, $documents->currentPage() - 1), min($documents->lastPage(), $documents->currentPage() + 2)) as $page => $url)
                                        <a href="{{ $url }}"
                                           @class([
                                               'flex h-8 min-w-8 items-center justify-center rounded-lg px-2 text-xs font-medium',
                                               'bg-sage-600 text-white' => $page === $documents->currentPage(),
                                               'border border-gray-200 text-gray-600 hover:bg-gray-50' => $page !== $documents->currentPage(),
                                           ])>
                                            {{ $page }}
                                        </a>
                                    @endforeach

                                    @if($documents->hasMorePages())
                                        <a href="{{ $documents->nextPageUrl() }}" class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-600 hover:bg-gray-50">›</a>
                                    @else
                                        <span class="flex h-8 w-8 items-center justify-center rounded-lg text-gray-300">›</span>
                                    @endif
                                </div>

                                <div class="relative">
                                    <select onchange="window.location.href='{{ $filterUrl(['per_page' => '__PER_PAGE__', 'page' => null]) }}'.replace('__PER_PAGE__', this.value)"
                                            class="h-8 appearance-none rounded-lg border border-gray-200 bg-white py-1 pl-2 pr-7 text-xs text-gray-600 outline-none">
                                        @foreach([8, 12, 16, 20] as $option)
                                            <option value="{{ $option }}" @selected($perPage === $option)>{{ $option }} / halaman</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                        </div>
                    @endif
                </div>
            </div>

            {{-- Right sidebar --}}
            <div class="space-y-4 lg:col-span-4">
                <div class="dashboard-card p-5">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Penyimpanan</h3>
                    <div class="mt-5 flex items-center gap-5">
                        <div class="relative h-[110px] w-[110px] shrink-0">
                            <svg class="h-[110px] w-[110px] -rotate-90" viewBox="0 0 120 120">
                                <circle cx="60" cy="60" r="48" fill="none" stroke="#e8ede6" stroke-width="12" />
                                <circle cx="60" cy="60" r="48" fill="none" stroke="#6b8e6b" stroke-width="12" stroke-linecap="round"
                                        stroke-dasharray="{{ 2 * 3.14159 * 48 }}"
                                        stroke-dashoffset="{{ 2 * 3.14159 * 48 * (1 - $storage['used_percent'] / 100) }}" />
                            </svg>
                            <div class="absolute inset-0 flex flex-col items-center justify-center text-center">
                                <span class="text-xl font-bold text-sage-800">{{ $storage['used_percent'] }}%</span>
                                <span class="text-[10px] text-sage-600">Terpakai</span>
                            </div>
                        </div>
                        <div class="min-w-0 space-y-2 text-[12px]">
                            <p class="text-gray-500">Total Penyimpanan</p>
                            <p class="text-sm font-semibold text-wedding-ink">{{ $storage['quota_gb'] }} GB</p>
                            <div class="flex items-center gap-2 text-gray-700">
                                <span class="h-2.5 w-2.5 rounded-full bg-sage-500"></span>
                                <span>Terpakai</span>
                                <span class="ml-auto font-medium">{{ number_format($storage['used_gb'], 1, ',', '.') }} GB</span>
                            </div>
                            <div class="flex items-center gap-2 text-gray-700">
                                <span class="h-2.5 w-2.5 rounded-full bg-gray-300"></span>
                                <span>Tersedia</span>
                                <span class="ml-auto font-medium">{{ number_format($storage['available_gb'], 1, ',', '.') }} GB</span>
                            </div>
                        </div>
                    </div>
                    <button type="button" class="mt-5 inline-flex h-11 w-full items-center justify-center rounded-xl border border-gray-200 bg-white text-sm font-medium text-wedding-ink hover:bg-gray-50">
                        Kelola Penyimpanan
                    </button>
                </div>

                <div class="dashboard-card p-5">
                    <div class="mb-4 flex items-center justify-between">
                        <h3 class="text-[15px] font-semibold text-wedding-ink">Terbaru Diupload</h3>
                        <a href="{{ $filterUrl(['folder' => DocumentFolder::All, 'page' => null]) }}" class="text-xs font-medium text-sage-600 hover:text-sage-800">Lihat Semua</a>
                    </div>
                    <div class="space-y-3">
                        @foreach($recentUploads as $document)
                            @php $badge = DokumenController::fileBadge($document['file_name'], $document['mime_type']); @endphp
                            <div class="flex items-center gap-3">
                                <div @class(['flex h-9 w-9 shrink-0 items-center justify-center rounded-lg', $badge['bg']])>
                                    <span @class(['text-[8px] font-bold', $badge['color']])>{{ $badge['label'] }}</span>
                                </div>
                                <div class="min-w-0 flex-1">
                                    <p class="truncate text-sm font-medium text-wedding-ink">{{ $document['file_name'] }}</p>
                                    <p class="text-[11px] text-gray-500">{{ $document['uploaded_at']->diffForHumans() }}</p>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>

                <div class="dashboard-card relative overflow-hidden p-5">
                    <h3 class="text-[15px] font-semibold text-wedding-ink">Tips Menyimpan Dokumen</h3>
                    <ul class="mt-4 space-y-3 text-sm text-gray-600">
                        <li class="flex items-start gap-2.5">
                            <svg class="mt-0.5 h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5V18a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v.75m12 0V9a2.25 2.25 0 0 0-2.25-2.25H9A2.25 2.25 0 0 0 6.75 9v10.5" />
                            </svg>
                            Gunakan format PDF untuk kontrak dan surat resmi.
                        </li>
                        <li class="flex items-start gap-2.5">
                            <svg class="mt-0.5 h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M7.5 8.25h9m-9 3H12m-9.75 1.51c0 1.6 1.123 2.994 2.707 3.227 1.087.16 2.185.283 3.293.369V21l4.184-4.183a1.14 1.14 0 0 1 .778-.332 48.294 48.294 0 0 0 5.83-.498c1.585-.233 2.708-1.626 2.708-3.228V6.741c0-1.602-1.123-2.995-2.707-3.228A48.394 48.394 0 0 0 12 3c-2.392 0-4.744.175-7.043.513C3.373 3.746 2.25 5.14 2.25 6.741v6.018Z" />
                            </svg>
                            Beri nama file yang jelas agar mudah dicari.
                        </li>
                        <li class="flex items-start gap-2.5">
                            <svg class="mt-0.5 h-4 w-4 shrink-0 text-sage-600" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 0 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                            </svg>
                            Cadangkan dokumen penting secara berkala.
                        </li>
                    </ul>
                    <a href="#" class="mt-4 inline-flex items-center gap-1 text-xs font-medium text-sage-600 hover:text-sage-800">
                        Pelajari Lebih Lanjut
                        <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" />
                        </svg>
                    </a>
                    <img src="{{ asset('images/dashboard-floral.svg') }}" alt="" class="pointer-events-none absolute -bottom-2 -right-2 w-24 opacity-40">
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
