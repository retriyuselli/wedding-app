@extends('layouts.app')

@section('heading', 'Tambah Uang Masuk')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('uang-masuk.store') }}" class="space-y-4">
        @csrf
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Nama Pengirim <span class="text-red-400">*</span></label>
            <input name="sender_name" type="text" value="{{ old('sender_name') }}" placeholder="Nama pengirim"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-violet-400 focus:outline-none {{ $errors->has('sender_name') ? 'border-red-400' : 'border-gray-200' }}">
            @error('sender_name') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Jumlah (Rp) <span class="text-red-400">*</span></label>
            <input name="amount" type="number" min="0" value="{{ old('amount') }}" placeholder="0"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-violet-400 focus:outline-none {{ $errors->has('amount') ? 'border-red-400' : 'border-gray-200' }}">
            @error('amount') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Tanggal Transfer <span class="text-red-400">*</span></label>
            <input name="transfer_date" type="date" value="{{ old('transfer_date', now()->format('Y-m-d')) }}"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-violet-400 focus:outline-none {{ $errors->has('transfer_date') ? 'border-red-400' : 'border-gray-200' }}">
            @error('transfer_date') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Bank / Dompet</label>
            <input name="bank_name" type="text" value="{{ old('bank_name') }}" placeholder="BCA, BRI, GoPay, dll"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-violet-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Keterangan</label>
            <input name="description" type="text" value="{{ old('description') }}" placeholder="Untuk apa?"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-violet-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">No. Referensi</label>
            <input name="reference_number" type="text" value="{{ old('reference_number') }}" placeholder="No. bukti transfer"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-violet-400 focus:outline-none">
        </div>
        <div class="flex gap-2 pt-2">
            <button type="submit"
                    class="flex-1 rounded-xl bg-violet-500 py-3 text-sm font-semibold text-white hover:bg-violet-600 active:scale-95">
                Simpan
            </button>
            <a href="{{ route('uang-masuk') }}"
               class="rounded-xl bg-gray-100 px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-200">
                Batal
            </a>
        </div>
    </form>
</div>
@endsection
