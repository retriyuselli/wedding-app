<?php

namespace App\Http\Controllers;

use App\Models\WeddingIncomingPayment;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class UangMasukController extends Controller
{
    public function index(Request $request): View
    {
        $query = WeddingIncomingPayment::where('user_id', Auth::id());

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $payments = $query->orderByDesc('transfer_date')->get();

        $totalConfirmed = WeddingIncomingPayment::where('user_id', Auth::id())
            ->where('status', 'confirmed')->sum('amount');

        $totalAll = WeddingIncomingPayment::where('user_id', Auth::id())->sum('amount');

        return view('uang-masuk.index', compact('payments', 'totalConfirmed', 'totalAll'));
    }

    public function create(): View
    {
        return view('uang-masuk.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'sender_name' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'transfer_date' => ['required', 'date'],
        ]);

        WeddingIncomingPayment::create([
            'user_id' => Auth::id(),
            'bank_name' => $request->bank_name ?: null,
            'amount' => $request->amount,
            'transfer_date' => $request->transfer_date,
            'sender_name' => $request->sender_name,
            'description' => $request->description ?: null,
            'reference_number' => $request->reference_number ?: null,
            'notes' => $request->notes ?: null,
            'status' => 'menunggu',
        ]);

        return redirect()->route('uang-masuk')->with('success', 'Pembayaran berhasil ditambahkan.');
    }

    public function edit(int $id): View
    {
        $payment = WeddingIncomingPayment::where('user_id', Auth::id())->findOrFail($id);

        return view('uang-masuk.edit', compact('payment'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $request->validate([
            'sender_name' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'transfer_date' => ['required', 'date'],
        ]);

        WeddingIncomingPayment::where('user_id', Auth::id())->findOrFail($id)->update([
            'bank_name' => $request->bank_name ?: null,
            'amount' => $request->amount,
            'transfer_date' => $request->transfer_date,
            'sender_name' => $request->sender_name,
            'description' => $request->description ?: null,
            'reference_number' => $request->reference_number ?: null,
            'notes' => $request->notes ?: null,
        ]);

        return redirect()->route('uang-masuk')->with('success', 'Pembayaran berhasil diperbarui.');
    }

    public function destroy(int $id): RedirectResponse
    {
        WeddingIncomingPayment::where('user_id', Auth::id())->findOrFail($id)->delete();

        return redirect()->route('uang-masuk')->with('success', 'Pembayaran berhasil dihapus.');
    }
}
