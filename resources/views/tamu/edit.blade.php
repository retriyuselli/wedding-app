@extends('layouts.app')

@section('heading', 'Edit Tamu')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('tamu.update', [$tab, $record->id]) }}" class="space-y-4">
        @csrf @method('PUT')

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama <span class="text-red-400">*</span></label>
            <input name="name" type="text" value="{{ old('name', $record->name) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('name') ? 'border-red-400' : 'border-gray-200' }}">
            @error('name') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">No. HP</label>
            <input name="phone" type="tel" value="{{ old('phone', $record->phone) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>

        @if($tab === 'umum')
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Email</label>
            <input name="email" type="email" value="{{ old('email', $record->email) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('email') ? 'border-red-400' : 'border-gray-200' }}">
            @error('email') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">No. Meja</label>
            <input name="table_number" type="text" value="{{ old('table_number', $record->table_number) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        @endif

        @if($tab === 'keluarga')
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Peran / Hubungan</label>
            <input name="role" type="text" value="{{ old('role', $record->role) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        @endif

        @if($tab === 'vip')
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jabatan</label>
            <input name="jabatan" type="text" value="{{ old('jabatan', $record->jabatan) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Instansi</label>
            <input name="instansi" type="text" value="{{ old('instansi', $record->instansi) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Kategori</label>
            <select name="kategori" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                @foreach(\App\Models\VipGuest::$kategoriOptions as $key => $label)
                    <option value="{{ $key }}" {{ old('kategori', $record->kategori) === $key ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
            </select>
        </div>
        @endif

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Status RSVP</label>
            <select name="rsvp_status" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="menunggu" {{ old('rsvp_status', $record->rsvp_status) === 'menunggu' ? 'selected' : '' }}>Menunggu</option>
                <option value="hadir" {{ old('rsvp_status', $record->rsvp_status) === 'hadir' ? 'selected' : '' }}>Hadir</option>
                <option value="tidak_hadir" {{ old('rsvp_status', $record->rsvp_status) === 'tidak_hadir' ? 'selected' : '' }}>Tidak Hadir</option>
            </select>
        </div>

        <div class="flex gap-2 pt-2">
            <button type="submit"
                    class="flex-1 rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan
            </button>
            <a href="{{ route('tamu', ['tab' => $tab]) }}"
               class="rounded-xl bg-gray-100 px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-200">
                Batal
            </a>
        </div>
    </form>

    <form method="POST" action="{{ route('tamu.destroy', [$tab, $record->id]) }}" class="mt-4">
        @csrf @method('DELETE')
        <button type="submit" onclick="return confirm('Hapus tamu ini?')"
                class="w-full rounded-xl border border-red-200 py-3 text-sm font-medium text-red-500 hover:bg-red-50">
            Hapus
        </button>
    </form>
</div>
@endsection
