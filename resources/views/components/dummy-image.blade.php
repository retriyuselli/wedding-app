@props([
    'type' => 'avatar',
    'index' => 0,
    'alt' => '',
])

<img src="{{ \App\Support\DummyImage::url($type, $index) }}" alt="{{ $alt ?? '' }}" {{ $attributes }}>
