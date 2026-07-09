@php
    $user = $user ?? auth()->user();
    $info = $info ?? $user->weddingInfo;
@endphp

<div id="account" class="dashboard-card scroll-mt-24 overflow-hidden">
    <div class="border-b border-gray-100 px-5 py-4">
        <h3 class="text-[15px] font-semibold text-wedding-ink">Informasi Akun</h3>
        <p class="mt-0.5 text-xs text-gray-500">Perbarui nama, email, dan kontak Anda</p>
    </div>
    <form method="POST" action="{{ route('profil.update') }}" class="space-y-4 p-5">
        @csrf
        @method('PUT')

        @if(session('success_profile'))
            <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
                {{ session('success_profile') }}
            </div>
        @endif

        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Nama Lengkap</label>
            <input name="name" type="text" value="{{ old('name', $user->name) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2 {{ $errors->has('name') ? 'border-red-400' : 'border-gray-200' }}">
            @error('name') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Email</label>
            <input name="email" type="email" value="{{ old('email', $user->email) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2 {{ $errors->has('email') ? 'border-red-400' : 'border-gray-200' }}">
            @error('email') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">WhatsApp</label>
            <input name="whatsapp" type="tel" value="{{ old('whatsapp', $user->whatsapp) }}" placeholder="08xx"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2">
        </div>
        <button type="submit" class="inline-flex h-11 items-center justify-center rounded-xl bg-sage-600 px-5 text-sm font-medium text-white hover:bg-sage-700">
            Simpan Perubahan
        </button>
    </form>
</div>

<div id="wedding" class="dashboard-card scroll-mt-24 overflow-hidden">
    <div class="border-b border-gray-100 px-5 py-4">
        <h3 class="text-[15px] font-semibold text-wedding-ink">Detail Pernikahan</h3>
        <p class="mt-0.5 text-xs text-gray-500">Nama pengantin dan budaya pernikahan</p>
    </div>
    <form method="POST" action="{{ route('profil.wedding') }}" class="space-y-4 p-5">
        @csrf
        @method('PUT')

        @if(session('success_wedding'))
            <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
                {{ session('success_wedding') }}
            </div>
        @endif

        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Nama Pengantin Pria</label>
            <input name="groom_name" type="text" value="{{ old('groom_name', $info?->groom_name) }}"
                   placeholder="Nama lengkap"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2">
        </div>
        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Nama Pengantin Wanita</label>
            <input name="bride_name" type="text" value="{{ old('bride_name', $info?->bride_name) }}"
                   placeholder="Nama lengkap"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2">
        </div>
        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Budaya / Adat</label>
            <input name="budaya" type="text" value="{{ old('budaya', $info?->budaya) }}"
                   placeholder="Misal: Jawa, Sunda, Minang"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2">
        </div>
        <button type="submit" class="inline-flex h-11 items-center justify-center rounded-xl bg-sage-600 px-5 text-sm font-medium text-white hover:bg-sage-700">
            Simpan Detail Pernikahan
        </button>
    </form>
</div>

<div id="security" class="dashboard-card scroll-mt-24 overflow-hidden">
    <div class="border-b border-gray-100 px-5 py-4">
        <h3 class="text-[15px] font-semibold text-wedding-ink">Privasi & Keamanan</h3>
        <p class="mt-0.5 text-xs text-gray-500">Ubah password akun Anda</p>
    </div>
    <form method="POST" action="{{ route('profil.password') }}" class="space-y-4 p-5">
        @csrf
        @method('PUT')

        @if(session('success_password'))
            <div class="flex items-center gap-2 rounded-xl bg-emerald-50 px-4 py-2 text-sm text-emerald-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
                {{ session('success_password') }}
            </div>
        @endif

        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Password Saat Ini</label>
            <input name="current_password" type="password"
                   class="w-full rounded-xl border px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2 {{ $errors->has('current_password') ? 'border-red-400' : 'border-gray-200' }}">
            @error('current_password') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Password Baru</label>
            <input name="new_password" type="password"
                   class="w-full rounded-xl border px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2 {{ $errors->has('new_password') ? 'border-red-400' : 'border-gray-200' }}">
            @error('new_password') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1.5 block text-sm font-medium text-gray-700">Konfirmasi Password Baru</label>
            <input name="new_password_confirmation" type="password"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none ring-sage-300 focus:ring-2">
        </div>
        <button type="submit" class="inline-flex h-11 items-center justify-center rounded-xl bg-sage-600 px-5 text-sm font-medium text-white hover:bg-sage-700">
            Ubah Password
        </button>
    </form>
</div>
