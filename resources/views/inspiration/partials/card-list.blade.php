@php
    $isSaved = in_array($inspiration->id, $savedIds, true);
@endphp

<article class="flex gap-4 p-4 hover:bg-gray-50/80">
    <img src="{{ $inspiration->coverImageUrl() }}" alt="{{ $inspiration->title }}" class="h-20 w-28 shrink-0 rounded-xl object-cover">
    <div class="min-w-0 flex-1">
        <div class="flex items-start justify-between gap-2">
            <div>
                <h3 class="text-sm font-semibold text-wedding-ink">{{ $inspiration->title }}</h3>
                <p class="mt-0.5 text-xs text-gray-400">{{ $inspiration->categoryLabel() }} · {{ $inspiration->photoCount() }} Foto</p>
            </div>
            <form method="POST" action="{{ route('inspiration.save', $inspiration->id) }}">
                @csrf
                <button type="submit" class="{{ $isSaved ? 'text-sage-700' : 'text-gray-300 hover:text-sage-700' }}">
                    <svg class="h-4 w-4 {{ $isSaved ? 'fill-current' : '' }}" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0 1 11.186 0Z" />
                    </svg>
                </button>
            </form>
        </div>
        <p class="mt-2 line-clamp-2 text-xs text-gray-500">{{ $inspiration->description }}</p>
    </div>
</article>
