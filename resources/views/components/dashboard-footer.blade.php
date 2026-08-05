<footer class="mt-4 border-t border-gray-200 bg-white py-10 lg:mt-8">
    <div class="dashboard-shell">
        <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
            <div>
                <div class="flex items-center gap-2">
                    <div class="flex h-9 w-9 items-center justify-center rounded-full bg-sage-100 text-sage-700">
                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                    </div>
                    <span class="font-semibold text-wedding-ink">Wedding App</span>
                </div>
                <p class="mt-3 text-sm leading-relaxed text-gray-500">
                    Rencanakan pernikahan impian dengan mudah, terorganisir, dan penuh kebahagiaan.
                </p>
            </div>

            <div>
                <p class="text-sm font-semibold text-wedding-ink">Aplikasi</p>
                <ul class="mt-3 space-y-2 text-sm text-gray-500">
                    <li><a href="{{ route('dashboard') }}" class="hover:text-sage-700">Home</a></li>
                    <li><a href="{{ route('checklist') }}" class="hover:text-sage-700">Checklist</a></li>
                    <li><a href="{{ route('tamu') }}" class="hover:text-sage-700">Guest</a></li>
                    <li><a href="{{ route('biaya') }}" class="hover:text-sage-700">Budget</a></li>
                </ul>
            </div>

            <div>
                <p class="text-sm font-semibold text-wedding-ink">Bantuan</p>
                <ul class="mt-3 space-y-2 text-sm text-gray-500">
                    <li><a href="{{ route('profil') }}" class="hover:text-sage-700">FAQ</a></li>
                    <li><a href="{{ route('privacy-policy') }}" class="hover:text-sage-700">Privasi & Keamanan</a></li>
                    <li><a href="{{ route('terms') }}" class="hover:text-sage-700">Syarat & Ketentuan</a></li>
                </ul>
            </div>

            <div>
                <p class="text-sm font-semibold text-wedding-ink">Unduh Aplikasi</p>
                <div class="mt-3 flex flex-col gap-2">
                    <span class="inline-flex h-10 items-center justify-center rounded-xl border border-gray-200 bg-gray-50 text-xs font-medium text-gray-600">App Store</span>
                    <span class="inline-flex h-10 items-center justify-center rounded-xl border border-gray-200 bg-gray-50 text-xs font-medium text-gray-600">Google Play</span>
                </div>
            </div>
        </div>

        <p class="mt-8 text-center text-xs text-gray-400">© {{ date('Y') }} Wedding App. All rights reserved.</p>
    </div>
</footer>
