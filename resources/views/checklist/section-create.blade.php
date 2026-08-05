@extends('layouts.app')

@section('heading', 'Tambah Seksi')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('checklist.sections.store') }}" class="space-y-4">
        @csrf
        <input type="hidden" name="event_id" value="{{ $eventId }}">

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Seksi <span class="text-red-400">*</span></label>
            <input name="title" type="text" value="{{ old('title') }}" placeholder="Misal: Dekorasi"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('title') ? 'border-red-400' : 'border-gray-200' }}">
            @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div class="flex gap-2 pt-2">
            <button type="submit"
                    class="flex-1 rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan
            </button>
            <a href="{{ route('checklist', $eventId ? ['event' => $eventId] : []) }}"
               class="rounded-xl bg-gray-100 px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-200">
                Batal
            </a>
        </div>
    </form>
</div>
@endsection
