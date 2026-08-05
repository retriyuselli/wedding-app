@extends('layouts.app')

@section('heading', 'Tambah Acara')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('checklist.events.store') }}" class="space-y-4">
        @csrf
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jenis Acara <span class="text-red-400">*</span></label>
            <select name="jenis_acara" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="lamaran" {{ old('jenis_acara') === 'lamaran' ? 'selected' : '' }}>Lamaran</option>
                <option value="pengajian" {{ old('jenis_acara') === 'pengajian' ? 'selected' : '' }}>Pengajian</option>
                <option value="akad" {{ old('jenis_acara') === 'akad' ? 'selected' : '' }}>Akad Nikah</option>
                <option value="resepsi" {{ old('jenis_acara') === 'resepsi' ? 'selected' : '' }}>Resepsi</option>
            </select>
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Tanggal Acara</label>
            <input name="tgl_acara" type="date" value="{{ old('tgl_acara') }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Lokasi</label>
            <input name="lokasi_acara" type="text" value="{{ old('lokasi_acara') }}" placeholder="Nama gedung / venue"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Catatan</label>
            <textarea name="catatan" rows="3" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">{{ old('catatan') }}</textarea>
        </div>
        <div class="flex gap-2 pt-2">
            <button type="submit"
                    class="flex-1 rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan
            </button>
            <a href="{{ route('checklist') }}"
               class="rounded-xl bg-gray-100 px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-200">
                Batal
            </a>
        </div>
    </form>
</div>
@endsection
