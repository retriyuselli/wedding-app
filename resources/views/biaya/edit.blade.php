@extends('layouts.app')

@section('heading', 'Edit Jadwal Bayar')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('biaya.update', $schedule->id) }}" class="space-y-4">
        @csrf @method('PUT')
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Item <span class="text-red-400">*</span></label>
            <input name="title" type="text" value="{{ old('title', $schedule->title) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('title') ? 'border-red-400' : 'border-gray-200' }}">
            @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Vendor</label>
            <input name="vendor_name" type="text" value="{{ old('vendor_name', $schedule->vendor_name) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Kategori</label>
            <select name="category" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                @foreach(\App\Models\WeddingPaymentSchedule::$categoryOptions as $key => $label)
                    <option value="{{ $key }}" {{ old('category', $schedule->category) === $key ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jumlah (Rp) <span class="text-red-400">*</span></label>
            <input name="amount" type="number" min="0" value="{{ old('amount', $schedule->amount) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('amount') ? 'border-red-400' : 'border-gray-200' }}">
            @error('amount') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jatuh Tempo</label>
            <input name="due_date" type="date" value="{{ old('due_date', $schedule->due_date?->format('Y-m-d')) }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Status</label>
            <select name="status" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="pending" {{ old('status', $schedule->status) === 'pending' ? 'selected' : '' }}>Belum Bayar</option>
                <option value="paid" {{ old('status', $schedule->status) === 'paid' ? 'selected' : '' }}>Sudah Bayar</option>
                <option value="overdue" {{ old('status', $schedule->status) === 'overdue' ? 'selected' : '' }}>Overdue</option>
            </select>
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Acara</label>
            <select name="event_id" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="">— Pilih Acara —</option>
                @foreach($events as $event)
                    <option value="{{ $event->id }}" {{ old('event_id', $schedule->wedding_event_id) == $event->id ? 'selected' : '' }}>{{ $event->jenis_label }}</option>
                @endforeach
            </select>
        </div>
        <div class="flex gap-2 pt-2">
            <button type="submit"
                    class="flex-1 rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan
            </button>
            <a href="{{ route('biaya') }}"
               class="rounded-xl bg-gray-100 px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-200">
                Batal
            </a>
        </div>
    </form>

    <form method="POST" action="{{ route('biaya.destroy', $schedule->id) }}" class="mt-4">
        @csrf @method('DELETE')
        <button type="submit" onclick="return confirm('Hapus jadwal ini?')"
                class="w-full rounded-xl border border-red-200 py-3 text-sm font-medium text-red-500 hover:bg-red-50">
            Hapus
        </button>
    </form>
</div>
@endsection
