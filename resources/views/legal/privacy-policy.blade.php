<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kebijakan Privasi — {{ $appName }}</title>
    <meta name="description" content="Kebijakan Privasi {{ $appName }} — cara kami mengumpulkan, menggunakan, dan melindungi data pribadi Anda.">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen bg-gradient-to-b from-[#f7f5f0] to-[#eef2eb] text-[#243329] antialiased">
    <div class="mx-auto max-w-3xl px-5 py-10 sm:px-8 sm:py-14">
        <header class="mb-8 text-center">
            <a href="{{ $websiteUrl }}" class="inline-flex items-center gap-2 text-sm text-[#3d5c49] hover:text-[#2a4033]">
                <span aria-hidden="true">←</span>
                <span>{{ $websiteDisplay }}</span>
            </a>
            <h1 class="mt-6 text-3xl font-semibold tracking-tight text-[#2a4033] sm:text-4xl">Kebijakan Privasi</h1>
            <p class="mt-2 text-sm text-[#5f6f64]">{{ $appName }}</p>
            <p class="mt-1 text-xs text-[#7a8a80]">Terakhir diperbarui {{ $lastUpdated }}</p>
        </header>

        <section class="mb-6 rounded-2xl border border-[#d8e2d8] bg-white/90 p-6 shadow-sm">
            <div class="flex items-start gap-4">
                <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-[#e8efe8] text-[#3d5c49]">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75m-3-7.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285Z" />
                    </svg>
                </div>
                <p class="text-sm leading-7 text-[#4d5d53]">{{ $introduction }}</p>
            </div>
        </section>

        @foreach ($sections as $section)
            <section class="mb-5 rounded-2xl border border-[#d8e2d8] bg-white/90 p-6 shadow-sm">
                <h2 class="text-lg font-semibold text-[#2a4033]">{{ $section['title'] }}</h2>

                @foreach ($section['paragraphs'] as $paragraph)
                    <p class="mt-3 whitespace-pre-line text-sm leading-7 text-[#4d5d53]">{{ $paragraph }}</p>
                @endforeach

                @if (! empty($section['bullets']))
                    <ul class="mt-4 space-y-3">
                        @foreach ($section['bullets'] as $bullet)
                            <li class="flex gap-3 text-sm leading-7 text-[#4d5d53]">
                                <span class="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-[#3d5c49]"></span>
                                <span>{{ $bullet }}</span>
                            </li>
                        @endforeach
                    </ul>
                @endif
            </section>
        @endforeach

        <footer class="mt-10 rounded-2xl border border-[#d8e2d8] bg-[#edf3ed] p-6 text-center text-sm text-[#5f6f64]">
            <p class="font-medium text-[#2a4033]">Butuh bantuan terkait privasi?</p>
            <p class="mt-2">Hubungi kami di
                <a href="mailto:{{ $contactEmail }}" class="font-medium text-[#3d5c49] underline underline-offset-2">{{ $contactEmail }}</a>
            </p>
            <p class="mt-4 text-xs">© {{ date('Y') }} {{ $appName }}. {{ $developer }}.</p>
        </footer>
    </div>
</body>
</html>
