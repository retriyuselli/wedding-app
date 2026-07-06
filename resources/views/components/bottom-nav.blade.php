<nav class="fixed bottom-0 left-1/2 z-30 w-full max-w-md -translate-x-1/2 border-t border-gray-100 bg-white">
    <div class="flex items-center justify-around px-2 py-2">

        {{-- Dashboard --}}
        <a href="{{ route('dashboard') }}"
           class="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-colors
                  {{ request()->routeIs('dashboard') ? 'text-rose-500' : 'text-gray-400 hover:text-gray-600' }}">
            <svg class="h-6 w-6" fill="{{ request()->routeIs('dashboard') ? 'currentColor' : 'none' }}"
                 viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
            </svg>
            <span class="text-xs font-medium">Beranda</span>
        </a>

        {{-- Checklist --}}
        <a href="{{ route('checklist') }}"
           class="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-colors
                  {{ request()->routeIs('checklist') ? 'text-rose-500' : 'text-gray-400 hover:text-gray-600' }}">
            <svg class="h-6 w-6" fill="{{ request()->routeIs('checklist') ? 'currentColor' : 'none' }}"
                 viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
            </svg>
            <span class="text-xs font-medium">Checklist</span>
        </a>

        {{-- Biaya --}}
        <a href="{{ route('biaya') }}"
           class="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-colors
                  {{ request()->routeIs('biaya') ? 'text-rose-500' : 'text-gray-400 hover:text-gray-600' }}">
            <svg class="h-6 w-6" fill="{{ request()->routeIs('biaya') ? 'currentColor' : 'none' }}"
                 viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z" />
            </svg>
            <span class="text-xs font-medium">Biaya</span>
        </a>

        {{-- Tamu --}}
        <a href="{{ route('tamu') }}"
           class="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-colors
                  {{ request()->routeIs('tamu') ? 'text-rose-500' : 'text-gray-400 hover:text-gray-600' }}">
            <svg class="h-6 w-6" fill="{{ request()->routeIs('tamu') ? 'currentColor' : 'none' }}"
                 viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
            </svg>
            <span class="text-xs font-medium">Tamu</span>
        </a>

        {{-- Profil --}}
        <a href="{{ route('profil') }}"
           class="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-colors
                  {{ request()->routeIs('profil') || request()->routeIs('uang-masuk') ? 'text-rose-500' : 'text-gray-400 hover:text-gray-600' }}">
            <svg class="h-6 w-6" fill="{{ request()->routeIs('profil') ? 'currentColor' : 'none' }}"
                 viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
            </svg>
            <span class="text-xs font-medium">Profil</span>
        </a>

    </div>
</nav>
