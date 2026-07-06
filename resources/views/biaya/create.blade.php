@extends('layouts.app')

@section('heading', 'Tambah Jadwal Bayar')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('biaya.store') }}" class="space-y-4">
        @csrf
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Item <span class="text-red-400">*</span></label>
            <input name="title" type="text" value="{{ old('title') }}" placeholder="Misal: DP Gedung"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('title') ? 'border-red-400' : 'border-gray-200' }}">
            @error('title') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Vendor</label>
            <input name="vendor_name" type="text" value="{{ old('vendor_name') }}" placeholder="Nama vendor / penyedia"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Kategori</label>
            <select name="category" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                @foreach(\App\Models\WeddingPaymentSchedule::$categoryOptions as $key => $label)
                    <option value="{{ $key }}" {{ old('category', 'other') === $key ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jumlah (Rp) <span class="text-red-400">*</span></label>
            <input name="amount" type="number" min="0" value="{{ old('amount') }}" placeholder="0"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('amount') ? 'border-red-400' : 'border-gray-200' }}">
            @error('amount') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jatuh Tempo</label>
            <input name="due_date" type="date" value="{{ old('due_date') }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Status <span class="text-red-400">*</span></label>
            <select name="status" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="pending" {{ old('status', 'pending') === 'pending' ? 'selected' : '' }}>Belum Bayar</option>
                <option value="paid" {{ old('status') === 'paid' ? 'selected' : '' }}>Sudah Bayar</option>
                <option value="overdue" {{ old('status') === 'overdue' ? 'selected' : '' }}>Overdue</option>
            </select>
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Acara</label>
            <select name="event_id" class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
                <option value="">— Pilih Acara —</option>
                @foreach($events as $event)
                    <option value="{{ $event->id }}" {{ old('event_id') == $event->id ? 'selected' : '' }}>{{ $event->jenis_label }}</option>
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
</div>
@endsection
