@php
    $isFavorite = in_array($vendor->id, $favoriteIds, true);
    $rating = $vendor->displayRating();
    $waPhone = preg_replace('/\D+/', '', $vendor->phone ?? '');
    if (str_starts_with($waPhone, '0')) {
        $waPhone = '62'.substr($waPhone, 1);
    }
@endphp

<article class="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm transition hover:shadow-md">
    <div class="relative">
        <img src="{{ $vendor->coverImageUrl() }}" alt="{{ $vendor->name }}" class="h-36 w-full object-cover">
        <span class="absolute bottom-2 left-2 rounded-md bg-white/90 px-2 py-1 text-[10px] font-semibold text-sage-700 backdrop-blur">
            {{ $vendor->displayCategoryName() }}
        </span>
        <form method="POST" action="{{ route('vendor.favorite', $vendor->id) }}" class="absolute right-2 top-2">
            @csrf
            <button type="submit" @class([
                'flex h-8 w-8 items-center justify-center rounded-full backdrop-blur transition',
                'bg-white text-rose-500' => $isFavorite,
                'bg-white/90 text-gray-400 hover:text-rose-500' => ! $isFavorite,
            ])>
                <svg class="h-4 w-4 {{ $isFavorite ? 'fill-current' : '' }}" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z" />
                </svg>
            </button>
        </form>
    </div>

    <div class="space-y-2 p-4">
        <div>
            <h3 class="truncate text-sm font-semibold text-wedding-ink">{{ $vendor->name }}</h3>
            <div class="mt-1 flex items-center gap-2 text-xs text-gray-500">
                <span class="inline-flex items-center gap-0.5 font-medium text-amber-600">
                    <svg class="h-3.5 w-3.5 fill-current" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 0 0 .95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 0 0-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 0 0-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 0 0-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 0 0 .951-.69l1.07-3.292Z"/></svg>
                    {{ number_format($rating, 1) }}
                </span>
                <span>({{ $vendor->reviewCount() }})</span>
            </div>
            <p class="mt-1 flex items-center gap-1 text-xs text-gray-400">
                <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 0 1-3 3m0 0a3 3 0 0 1-3-3m3 3V21m4.5-4.5a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                </svg>
                {{ $vendor->locationLabel() }}
            </p>
        </div>

        <div class="flex items-center gap-1.5 text-xs text-sage-600">
            <span class="h-2 w-2 rounded-full bg-sage-500"></span>
            Tersedia
        </div>

        <div class="flex items-center gap-1 border-t border-gray-100 pt-3">
            @if($vendor->phone)
                <a href="tel:{{ $vendor->phone }}" class="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-sage-600" title="Telepon">
                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z" /></svg>
                </a>
                @if($waPhone)
                    <a href="https://wa.me/{{ $waPhone }}" target="_blank" rel="noopener" class="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-sage-600" title="WhatsApp">
                        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 0 1-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 0 1-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994c-.003 5.45-4.435 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0-3.48-8.413Z"/></svg>
                    </a>
                @endif
            @endif
            @if($vendor->email)
                <a href="mailto:{{ $vendor->email }}" class="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-sage-600" title="Email">
                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" /></svg>
                </a>
            @endif
            <form method="POST" action="{{ route('vendor.favorite', $vendor->id) }}" class="ml-auto">
                @csrf
                <button type="submit" class="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-sage-600" title="Simpan">
                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0 1 11.186 0Z" /></svg>
                </button>
            </form>
        </div>
    </div>
</article>
