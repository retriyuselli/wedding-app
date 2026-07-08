@php
    $isFavorite = in_array($vendor->id, $favoriteIds, true);
    $rating = $vendor->displayRating();
@endphp

<article class="flex gap-4 p-4 hover:bg-gray-50/80">
    <img src="{{ $vendor->coverImageUrl() }}" alt="{{ $vendor->name }}" class="h-20 w-20 shrink-0 rounded-xl object-cover">
    <div class="min-w-0 flex-1">
        <div class="flex items-start justify-between gap-2">
            <div>
                <h3 class="text-sm font-semibold text-wedding-ink">{{ $vendor->name }}</h3>
                <p class="text-xs text-gray-400">{{ $vendor->category?->name }} · {{ $vendor->locationLabel() }}</p>
            </div>
            <form method="POST" action="{{ route('vendor.favorite', $vendor->id) }}">
                @csrf
                <button type="submit" class="{{ $isFavorite ? 'text-rose-500' : 'text-gray-300 hover:text-rose-500' }}">
                    <svg class="h-4 w-4 {{ $isFavorite ? 'fill-current' : '' }}" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z" />
                    </svg>
                </button>
            </form>
        </div>
        <div class="mt-2 flex flex-wrap items-center gap-3 text-xs">
            <span class="inline-flex items-center gap-0.5 font-medium text-amber-600">
                <svg class="h-3.5 w-3.5 fill-current" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 0 0 .95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 0 0-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 0 0-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 0 0-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 0 0 .951-.69l1.07-3.292Z"/></svg>
                {{ number_format($rating, 1) }} ({{ $vendor->reviewCount() }})
            </span>
            <span class="inline-flex items-center gap-1 text-sage-600"><span class="h-2 w-2 rounded-full bg-sage-500"></span> Tersedia</span>
        </div>
    </div>
</article>
