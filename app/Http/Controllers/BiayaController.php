<?php

namespace App\Http\Controllers;

use App\Models\WeddingBudget;
use App\Models\WeddingIncomingPayment;
use App\Models\WeddingPaymentSchedule;
use App\Models\WeddingQuote;
use App\Services\WeddingBudgetSummaryCalculator;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class BiayaController extends Controller
{
    public function index(
        Request $request,
        WeddingBudgetSummaryCalculator $budgetCalculator,
    ): View {
        $user = Auth::user();
        $weddingInfo = $user->weddingInfo;
        $events = $user->weddingEvents()->get();
        $tab = $request->string('tab')->toString() ?: 'ringkasan';
        $filter = $request->string('filter')->toString() ?: 'semua';

        $budgetSummary = $budgetCalculator->calculate($user);
        $budget = $user->weddingBudget;

        $spentByCategory = $user->paymentSchedules()
            ->where('status', 'paid')
            ->get()
            ->groupBy('category')
            ->map(fn (Collection $items): float => (float) $items->sum('amount'));

        $categoryRows = $this->buildCategoryRows($user, $spentByCategory);
        $categoryTotals = $this->buildCategoryTotals($categoryRows);

        $schedulesQuery = WeddingPaymentSchedule::query()
            ->where('user_id', $user->id);

        match ($filter) {
            'belum' => $schedulesQuery->where('status', 'pending'),
            'sudah' => $schedulesQuery->where('status', 'paid'),
            'overdue' => $schedulesQuery->where('status', 'overdue'),
            default => null,
        };

        $schedules = $schedulesQuery->orderByDesc('due_date')->get();

        $recentTransactions = WeddingPaymentSchedule::query()
            ->where('user_id', $user->id)
            ->where('status', 'paid')
            ->orderByDesc('paid_at')
            ->orderByDesc('due_date')
            ->limit(5)
            ->get();

        $incomingPayments = WeddingIncomingPayment::query()
            ->where('user_id', $user->id)
            ->orderByDesc('transfer_date')
            ->get();

        $chartSegments = $this->buildChartSegments($categoryRows, $budgetSummary['total_budget']);

        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->sortByDesc('tgl_acara')->first();

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        $savingsTip = WeddingQuote::query()
            ->where('is_active', true)
            ->inRandomOrder()
            ->value('quote') ?? 'Bandingkan minimal 3 vendor sebelum memutuskan agar anggaran lebih efisien.';

        $tabs = [
            ['key' => 'ringkasan', 'label' => 'Ringkasan'],
            ['key' => 'kategori', 'label' => 'Kategori'],
            ['key' => 'transaksi', 'label' => 'Transaksi'],
            ['key' => 'pemasukan', 'label' => 'Pemasukan'],
        ];

        return view('biaya.index', [
            'budget' => $budget,
            'budgetSummary' => $budgetSummary,
            'categoryRows' => $categoryRows,
            'categoryTotals' => $categoryTotals,
            'schedules' => $schedules,
            'recentTransactions' => $recentTransactions,
            'incomingPayments' => $incomingPayments,
            'chartSegments' => $chartSegments,
            'tabs' => $tabs,
            'activeTab' => $tab,
            'filter' => $filter,
            'coupleLabel' => $this->coupleLabel($weddingInfo, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d M Y'),
            'unreadNotifications' => $unreadNotifications,
            'savingsTip' => $savingsTip,
        ]);
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

    /**
     * @param  Collection<string, float>  $spentByCategory
     * @return Collection<int, array{
     *     category: string,
     *     category_key: string,
     *     description: string,
     *     allocated: float,
     *     spent: float,
     *     remaining: float,
     *     percent: int,
     *     color: string
     * }>
     */
    private function buildCategoryRows($user, Collection $spentByCategory): Collection
    {
        $colors = ['#6b8e6b', '#8aa68a', '#c29747', '#547054', '#b5c4b3', '#a67f3a', '#385745', '#d4b06a', '#2d4638'];

        $allocations = $user->budgetCategoryAllocations()->orderBy('category')->get();

        if ($allocations->isNotEmpty()) {
            return $allocations->values()->map(function ($allocation, int $index) use ($spentByCategory, $colors): array {
                $allocated = (float) $allocation->allocated_amount;
                $spent = (float) ($spentByCategory[$allocation->category] ?? 0);
                $remaining = max($allocated - $spent, 0);
                $percent = $allocated > 0 ? (int) min(100, round(($spent / $allocated) * 100)) : 0;

                return [
                    'category' => $allocation->category_label,
                    'category_key' => $allocation->category,
                    'description' => WeddingPaymentSchedule::categoryDescription($allocation->category),
                    'allocated' => $allocated,
                    'spent' => $spent,
                    'remaining' => $remaining,
                    'percent' => $percent,
                    'color' => $colors[$index % count($colors)],
                ];
            });
        }

        $grouped = $user->paymentSchedules()->get()->groupBy('category');

        if ($grouped->isEmpty()) {
            return collect();
        }

        return $grouped->values()->map(function (Collection $items, int $index) use ($colors): array {
            $categoryKey = $items->first()->category;
            $allocated = (float) $items->sum('amount');
            $spent = (float) $items->where('status', 'paid')->sum('amount');
            $remaining = max($allocated - $spent, 0);
            $percent = $allocated > 0 ? (int) min(100, round(($spent / $allocated) * 100)) : 0;

            return [
                'category' => WeddingPaymentSchedule::$categoryOptions[$categoryKey] ?? 'Lainnya',
                'category_key' => $categoryKey,
                'description' => WeddingPaymentSchedule::categoryDescription($categoryKey),
                'allocated' => $allocated,
                'spent' => $spent,
                'remaining' => $remaining,
                'percent' => $percent,
                'color' => $colors[$index % count($colors)],
            ];
        });
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $categoryRows
     * @return array{allocated: float, spent: float, remaining: float, percent: int}
     */
    private function buildCategoryTotals(Collection $categoryRows): array
    {
        $allocated = (float) $categoryRows->sum('allocated');
        $spent = (float) $categoryRows->sum('spent');
        $remaining = (float) $categoryRows->sum('remaining');
        $percent = $allocated > 0 ? (int) min(100, round(($spent / $allocated) * 100)) : 0;

        return compact('allocated', 'spent', 'remaining', 'percent');
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $categoryRows
     * @return Collection<int, array{label: string, percent: int, color: string, amount: float}>
     */
    private function buildChartSegments(Collection $categoryRows, float $totalBudget): Collection
    {
        $base = $totalBudget > 0 ? $totalBudget : (float) $categoryRows->sum('spent');

        if ($base <= 0) {
            return collect();
        }

        return $categoryRows
            ->sortByDesc('spent')
            ->take(5)
            ->values()
            ->map(fn (array $row): array => [
                'label' => $row['category'],
                'percent' => (int) round(($row['spent'] / $base) * 100),
                'color' => $row['color'],
                'amount' => $row['spent'],
            ]);
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
