<?php

namespace App\Http\Controllers;

use App\Models\WeddingBudget;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class BiayaController extends Controller
{
    public function index(Request $request): View
    {
        $filter = $request->get('filter', 'semua');
        $user = Auth::user();
        $budget = $user->weddingBudget;
        $events = $user->weddingEvents()->get();

        $query = WeddingPaymentSchedule::where('user_id', Auth::id());

        match ($filter) {
            'belum' => $query->where('status', 'pending'),
            'sudah' => $query->where('status', 'paid'),
            'overdue' => $query->where('status', 'overdue'),
            default => null,
        };

        $schedules = $query->orderBy('due_date')->get();
        $totalBudget = (float) ($budget?->total_budget ?? 0);
        $totalPaid = WeddingPaymentSchedule::where('user_id', Auth::id())->where('status', 'paid')->sum('amount');
        $totalPending = WeddingPaymentSchedule::where('user_id', Auth::id())->whereIn('status', ['pending', 'overdue'])->sum('amount');

        return view('biaya.index', compact('schedules', 'budget', 'events', 'totalBudget', 'totalPaid', 'totalPending', 'filter'));
    }

    public function create(): View
    {
        $events = Auth::user()->weddingEvents()->get();

        return view('biaya.create', compact('events'));
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'due_date' => ['nullable', 'date'],
            'status' => ['required', 'in:pending,paid,overdue'],
        ]);

        WeddingPaymentSchedule::create([
            'user_id' => Auth::id(),
            'title' => $request->title,
            'vendor_name' => $request->vendor_name ?: null,
            'category' => $request->category ?? 'other',
            'amount' => $request->amount,
            'due_date' => $request->due_date ?: null,
            'status' => $request->status,
            'notes' => $request->notes ?: null,
            'wedding_event_id' => $request->event_id ?: null,
            'paid_at' => $request->status === 'paid' ? now() : null,
        ]);

        return redirect()->route('biaya')->with('success', 'Tagihan berhasil ditambahkan.');
    }

    public function edit(int $id): View
    {
        $schedule = WeddingPaymentSchedule::where('user_id', Auth::id())->findOrFail($id);
        $events = Auth::user()->weddingEvents()->get();

        return view('biaya.edit', compact('schedule', 'events'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'due_date' => ['nullable', 'date'],
            'status' => ['required', 'in:pending,paid,overdue'],
        ]);

        WeddingPaymentSchedule::where('user_id', Auth::id())->findOrFail($id)->update([
            'title' => $request->title,
            'vendor_name' => $request->vendor_name ?: null,
            'category' => $request->category ?? 'other',
            'amount' => $request->amount,
            'due_date' => $request->due_date ?: null,
            'status' => $request->status,
            'notes' => $request->notes ?: null,
            'wedding_event_id' => $request->event_id ?: null,
            'paid_at' => $request->status === 'paid' ? now() : null,
        ]);

        return redirect()->route('biaya')->with('success', 'Tagihan berhasil diperbarui.');
    }

    public function destroy(int $id): RedirectResponse
    {
        WeddingPaymentSchedule::where('user_id', Auth::id())->findOrFail($id)->delete();

        return redirect()->route('biaya')->with('success', 'Tagihan berhasil dihapus.');
    }

    public function markPaid(int $id): RedirectResponse
    {
        WeddingPaymentSchedule::where('user_id', Auth::id())->findOrFail($id)
            ->update(['status' => 'paid', 'paid_at' => now()]);

        return back()->with('success', 'Tagihan ditandai sudah dibayar.');
    }

    public function editBudget(): View
    {
        $budget = Auth::user()->weddingBudget;

        return view('biaya.budget', compact('budget'));
    }

    public function updateBudget(Request $request): RedirectResponse
    {
        $request->validate(['total_budget' => ['required', 'numeric', 'min:0']]);

        Auth::user()->weddingBudget()->updateOrCreate(
            ['user_id' => Auth::id()],
            [
                'total_budget' => $request->total_budget,
                'currency' => $request->currency ?? WeddingBudget::defaultCurrency(),
                'notes' => $request->notes ?: null,
            ]
        );

        return redirect()->route('biaya')->with('success', 'Budget berhasil disimpan.');
    }
}
