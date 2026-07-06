@extends('layouts.app')

@section('heading', 'Tambah Task')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('checklist.tasks.store') }}" class="space-y-4">
        @csrf
        <input type="hidden" name="event_id" value="{{ $eventId }}">
        <input type="hidden" name="section_id" value="{{ $sectionId }}">

        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Task <span class="text-red-400">*</span></label>
            <input name="title" type="text" value="{{ old('title') }}" placeholder="Misal: Booking gedung"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('title') ? 'border-red-400' : 'border-gray-200' }}">
            @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Deadline (opsional)</label>
            <input name="due_date" type="date" value="{{ old('due_date') }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Seksi</label>
            <select name="section_id" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="">— Tanpa seksi —</option>
                @foreach($sections as $section)
                    <option value="{{ $section->id }}" {{ (old('section_id', $sectionId) == $section->id) ? 'selected' : '' }}>{{ $section->title }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Acara</label>
            <select name="event_id" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="">— Semua acara —</option>
                @foreach($events as $event)
                    <option value="{{ $event->id }}" {{ (old('event_id', $eventId) == $event->id) ? 'selected' : '' }}>{{ $event->jenis_label }}</option>
                @endforeach
            </select>
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
