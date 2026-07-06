@extends('layouts.app')

@section('heading', 'Edit Seksi')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('checklist.sections.update', $section->id) }}" class="space-y-4">
        @csrf @method('PUT')

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Seksi <span class="text-red-400">*</span></label>
            <input name="title" type="text" value="{{ old('title', $section->title) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('title') ? 'border-red-400' : 'border-gray-200' }}">
            @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
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

    <form method="POST" action="{{ route('checklist.sections.destroy', $section->id) }}" class="mt-4">
        @csrf @method('DELETE')
        <button type="submit" onclick="return confirm('Hapus seksi ini beserta semua task-nya?')"
                class="w-full rounded-xl border border-red-200 py-3 text-sm font-medium text-red-500 hover:bg-red-50">
            Hapus Seksi
        </button>
    </form>
</div>
@endsection
