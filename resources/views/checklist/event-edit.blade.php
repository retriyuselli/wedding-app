@extends('layouts.app')

@section('heading', 'Edit Acara')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('checklist.events.update', $event->id) }}" class="space-y-4">
        @csrf @method('PUT')
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jenis Acara <span class="text-red-400">*</span></label>
            <select name="jenis_acara" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="lamaran" {{ old('jenis_acara', $event->jenis_acara) === 'lamaran' ? 'selected' : '' }}>Lamaran</option>
                <option value="pengajian" {{ old('jenis_acara', $event->jenis_acara) === 'pengajian' ? 'selected' : '' }}>Pengajian</option>
                <option value="akad" {{ old('jenis_acara', $event->jenis_acara) === 'akad' ? 'selected' : '' }}>Akad Nikah</option>
                <option value="resepsi" {{ old('jenis_acara', $event->jenis_acara) === 'resepsi' ? 'selected' : '' }}>Resepsi</option>
            </select>
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Tanggal Acara</label>
            <input name="tgl_acara" type="date" value="{{ old('tgl_acara', $event->tgl_acara?->format('Y-m-d')) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Lokasi</label>
            <input name="lokasi_acara" type="text" value="{{ old('lokasi_acara', $event->lokasi_acara) }}" placeholder="Nama gedung / venue"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Catatan</label>
            <textarea name="catatan" rows="3" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">{{ old('catatan', $event->catatan) }}</textarea>
        </div>
        <div class="flex gap-2 pt-2">
            <button type="submit"
                    class="flex-1 rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan
            </button>
            <a href="{{ route('checklist', ['event' => $event->id]) }}"
               class="rounded-xl bg-gray-100 px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-200">
                Batal
            </a>
        </div>
    </form>

    <form method="POST" action="{{ route('checklist.events.destroy', $event->id) }}" class="mt-4">
        @csrf @method('DELETE')
        <button type="submit" onclick="return confirm('Hapus acara ini beserta semua datanya?')"
                class="w-full rounded-xl border border-red-200 py-3 text-sm font-medium text-red-500 hover:bg-red-50">
            Hapus Acara
        </button>
    </form>
</div>
@endsection
