@props([
    'name',
    'label',
    'description' => null,
    'checked' => false,
])

<div class="flex items-center justify-between gap-4 px-5 py-4">
    <div class="min-w-0">
        <p class="text-sm font-medium text-wedding-ink">{{ $label }}</p>
        @if($description)
            <p class="mt-0.5 text-xs text-gray-500">{{ $description }}</p>
        @endif
    </div>
    <label class="relative inline-flex shrink-0 cursor-pointer items-center">
        <input type="hidden" name="{{ $name }}" value="0">
        <input type="checkbox" name="{{ $name }}" value="1" @checked($checked) class="peer sr-only">
        <span class="relative h-6 w-11 rounded-full bg-gray-200 transition peer-checked:bg-sage-600 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-sage-200 after:absolute after:left-[2px] after:top-[2px] after:h-5 after:w-5 after:rounded-full after:bg-white after:shadow-sm after:transition-all peer-checked:after:translate-x-5"></span>
    </label>
</div>
