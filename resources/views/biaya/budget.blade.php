@extends('layouts.app')

@section('heading', 'Set Budget Total')

@section('content')
<div class="p-4">
    <form method="POST" action="{{ route('biaya.budget.update') }}" class="space-y-4">
        @csrf @method('PUT')
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Total Budget (Rp) <span class="text-red-400">*</span></label>
            <input name="total_budget" type="number" min="0" value="{{ old('total_budget', $budget?->total_budget) }}" placeholder="0"
                   class="w-full rounded-xl border px-4 py-3 text-sm focus:border-rose-400 focus:outline-none {{ $errors->has('total_budget') ? 'border-red-400' : 'border-gray-200' }}">
            @error('total_budget') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Mata Uang</label>
            <input name="currency" type="text" value="{{ old('currency', $budget?->currency ?? 'IDR') }}"
                   class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">
        </div>
        <div>
            <label class="mb-1 block text-sm font-medium text-gray-700">Catatan</label>
            <textarea name="notes" rows="3" placeholder="Catatan budget..."
                      class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm focus:border-rose-400 focus:outline-none">{{ old('notes', $budget?->notes) }}</textarea>
        </div>
        <div class="flex gap-2 pt-2">
            <button type="submit"
                    class="flex-1 rounded-xl bg-rose-500 py-3 text-sm font-semibold text-white hover:bg-rose-600 active:scale-95">
                Simpan Budget
            </button>
            <a href="{{ route('biaya') }}"
               class="rounded-xl bg-gray-100 px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-200">
                Batal
            </a>
        </div>
    </form>
</div>
@endsection
