@php
    $isSaved = in_array($inspiration->id, $savedIds, true);
    $palette = $inspiration->paletteColors();
@endphp

<article class="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm transition hover:shadow-md">
    <div class="relative">
        <img src="{{ $inspiration->coverImageUrl() }}" alt="{{ $inspiration->title }}" class="h-40 w-full object-cover">
        <form method="POST" action="{{ route('inspiration.save', $inspiration->id) }}" class="absolute right-2 top-2">
            @csrf
            <button type="submit" @class([
                'flex h-8 w-8 items-center justify-center rounded-full backdrop-blur transition',
                'bg-white text-sage-700' => $isSaved,
                'bg-white/90 text-gray-500 hover:text-sage-700' => ! $isSaved,
            ])>
                <svg class="h-4 w-4 {{ $isSaved ? 'fill-current' : '' }}" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0 1 11.186 0Z" />
                </svg>
            </button>
        </form>
    </div>

    <div class="space-y-2 p-4">
        <div>
            <h3 class="text-sm font-semibold text-wedding-ink">{{ $inspiration->title }}</h3>
            <p class="mt-1 line-clamp-2 text-xs text-gray-500">{{ $inspiration->description }}</p>
        </div>

        <div class="flex items-center justify-between">
            <div class="flex items-center gap-1">
                @foreach($palette as $color)
                    <span class="h-3 w-3 rounded-full ring-1 ring-gray-200" style="background-color: {{ $color }}"></span>
                @endforeach
            </div>
            <span class="text-[11px] text-gray-400">{{ $inspiration->photoCount() }} Foto</span>
        </div>
    </div>
</article>
