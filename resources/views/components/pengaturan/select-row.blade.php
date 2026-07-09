@props([
    'label',
    'description' => null,
])

<div class="px-5 py-4">
    <p class="text-sm font-medium text-wedding-ink">{{ $label }}</p>
    @if($description)
        <p class="mt-0.5 text-xs text-gray-500">{{ $description }}</p>
    @endif
    <div class="mt-3">
        {{ $slot }}
    </div>
</div>
