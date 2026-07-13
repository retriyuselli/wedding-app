<?php

namespace App\Http\Controllers;

use App\Models\CustomerPreparationTask;
use App\Models\Inspiration;
use App\Models\WeddingQuote;
use App\Services\CustomerPreparationSummaryCalculator;
use App\Services\WeddingBudgetSummaryCalculator;
use App\Support\VendorCatalog;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(
        CustomerPreparationSummaryCalculator $checklistCalculator,
        WeddingBudgetSummaryCalculator $budgetCalculator,
    ): View {
        $user = Auth::user();
        $weddingInfo = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        $countdownEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->filter(fn ($event) => $event->tgl_acara?->isFuture())->sortByDesc('tgl_acara')->first()
            ?? $events->sortByDesc('tgl_acara')->first();

        $countdownDate = $countdownEvent?->tgl_acara
            ? Carbon::parse($countdownEvent->tgl_acara)->endOfDay()
            : null;

        $checklistSummary = $checklistCalculator->calculate($user);
        $budgetSummary = $budgetCalculator->calculate($user);

        $upcomingTasks = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->whereIn('status', ['pending', 'in_progress'])
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(3)
            ->get();

        $eventProgress = $this->eventProgress($user->id);

        $featuredQuery = VendorCatalog::queryWithCategory()
            ->where('is_active', true);

        if (VendorCatalog::usingPaket()) {
            $featuredVendors = (clone $featuredQuery)
                ->where(function ($query): void {
                    $query->whereNotNull('badge')
                        ->where('badge', '!=', '[]')
                        ->orWhere(function ($promoQuery): void {
                            $promoQuery->whereNotNull('promo')->where('promo', '!=', '[]');
                        });
                })
                ->orderByDesc('likes')
                ->limit(6)
                ->get();

            if ($featuredVendors->isEmpty()) {
                $featuredVendors = $featuredQuery->orderByDesc('likes')->limit(6)->get();
            }
        } else {
            $featuredVendors = (clone $featuredQuery)
                ->where('is_featured', true)
                ->orderBy('sort_order')
                ->limit(6)
                ->get();

            if ($featuredVendors->isEmpty()) {
                $featuredVendors = $featuredQuery->orderBy('sort_order')->limit(6)->get();
            }
        }

        $savedInspirations = $user->savedInspirations()
            ->where('is_active', true)
            ->orderByPivot('created_at', 'desc')
            ->limit(3)
            ->get();

        if ($savedInspirations->isEmpty()) {
            $savedInspirations = Inspiration::query()
                ->where('is_active', true)
                ->orderBy('sort_order')
                ->limit(3)
                ->get();
        }

        $messageThreads = $user->messageThreads()
            ->with(['latestMessage'])
            ->limit(3)
            ->get();

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        $unreadMessages = $user->messageThreads()
            ->whereHas('messages', fn ($query) => $query
                ->where('is_outgoing', false)
                ->whereNull('read_at'))
            ->count();

        $allGuests = collect()
            ->merge($user->guests()->get(['rsvp_status']))
            ->merge($user->familyMembers()->get(['rsvp_status']))
            ->merge($user->vipGuests()->get(['rsvp_status']));

        $totalGuests = $allGuests->count();
        $confirmedGuests = $allGuests->where('rsvp_status', 'hadir')->count();
        $confirmedPercent = $totalGuests > 0 ? (int) round(($confirmedGuests / $totalGuests) * 100) : 0;

        $upcomingPaymentsTotal = (float) $user->paymentSchedules()
            ->whereIn('status', ['pending', 'overdue'])
            ->where('due_date', '>=', now()->startOfDay())
            ->where('due_date', '<=', now()->addDays(30))
            ->sum('amount');

        $tasksDueThisWeek = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->whereIn('status', ['pending', 'in_progress'])
            ->whereBetween('due_date', [now()->startOfDay(), now()->addDays(7)->endOfDay()])
            ->count();

        $coupleLabel = $this->coupleLabel($weddingInfo, $user->name);
        $mainLocation = $countdownEvent?->lokasi_acara
            ?? $events->firstWhere('jenis_acara', 'resepsi')?->lokasi_acara
            ?? $events->first()?->lokasi_acara;

        $eventTimeLabel = $this->eventTimeLabel($countdownEvent);

        $spentByCategory = $user->paymentSchedules()
            ->where('status', 'paid')
            ->get()
            ->groupBy('category')
            ->map(fn ($items) => (float) $items->sum('amount'));

        $budgetCategories = $user->budgetCategoryAllocations()
            ->orderBy('category')
            ->get()
            ->map(function ($allocation) use ($spentByCategory) {
                $allocated = (float) $allocation->allocated_amount;
                $spent = (float) ($spentByCategory[$allocation->category] ?? 0);
                $remaining = max($allocated - $spent, 0);
                $percent = $allocated > 0 ? (int) min(100, round(($spent / $allocated) * 100)) : 0;

                return [
                    'category' => $allocation->category_label,
                    'allocated' => $allocated,
                    'spent' => $spent,
                    'remaining' => $remaining,
                    'percent' => $percent,
                ];
            });

        $awaitingGuests = $allGuests->where('rsvp_status', 'menunggu')->count();
        $declinedGuests = $allGuests->where('rsvp_status', 'tidak_hadir')->count();

        $importantReminders = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->whereIn('status', ['pending', 'in_progress'])
            ->whereNotNull('due_date')
            ->where('due_date', '>=', now()->startOfDay())
            ->orderBy('due_date')
            ->limit(4)
            ->get();

        $dailyQuote = WeddingQuote::query()
            ->where('is_active', true)
            ->inRandomOrder()
            ->value('quote');

        return view('dashboard.index', [
            'weddingInfo' => $weddingInfo,
            'events' => $events,
            'countdownEvent' => $countdownEvent,
            'countdownDate' => $countdownDate,
            'eventTimeLabel' => $eventTimeLabel,
            'checklistSummary' => $checklistSummary,
            'budgetSummary' => $budgetSummary,
            'upcomingTasks' => $upcomingTasks,
            'eventProgress' => $eventProgress,
            'featuredVendors' => $featuredVendors,
            'savedInspirations' => $savedInspirations,
            'messageThreads' => $messageThreads,
            'unreadNotifications' => $unreadNotifications,
            'unreadMessages' => $unreadMessages,
            'coupleLabel' => $coupleLabel,
            'mainLocation' => $mainLocation,
            'budgetCategories' => $budgetCategories,
            'guestStats' => [
                'total' => $totalGuests,
                'confirmed' => $confirmedGuests,
                'awaiting' => $awaitingGuests,
                'declined' => $declinedGuests,
            ],
            'importantReminders' => $importantReminders,
            'dailyQuote' => $dailyQuote,
            'bottomStats' => [
                'total_guests' => $totalGuests,
                'confirmed_guests' => $confirmedGuests,
                'confirmed_percent' => $confirmedPercent,
                'total_vendors' => VendorCatalog::query()->where('is_active', true)->count(),
                'upcoming_payments' => $upcomingPaymentsTotal,
                'tasks_due_week' => $tasksDueThisWeek,
            ],
        ]);
    }

    /**
     * @return Collection<int, array{title: string, done: int, total: int, percent: int}>
     */
    private function eventProgress(int $userId): Collection
    {
        $labels = [
            'akad' => 'Akad Nikah',
            'resepsi' => 'Resepsi',
            'pengajian' => 'Pengajian',
        ];

        $progress = collect();

        foreach ($labels as $jenis => $title) {
            $tasks = CustomerPreparationTask::query()
                ->where('user_id', $userId)
                ->whereHas('weddingEvent', fn ($query) => $query->where('jenis_acara', $jenis))
                ->get();

            $total = $tasks->count();
            $done = $tasks->where('status', 'done')->count();

            $progress->push([
                'title' => $title,
                'done' => $done,
                'total' => $total,
                'percent' => $total > 0 ? (int) round(($done / $total) * 100) : 0,
            ]);
        }

        $otherTasks = CustomerPreparationTask::query()
            ->where('user_id', $userId)
            ->where(function ($query): void {
                $query->whereNull('wedding_event_id')
                    ->orWhereHas('weddingEvent', fn ($eventQuery) => $eventQuery->whereNotIn('jenis_acara', ['akad', 'resepsi', 'pengajian']));
            })
            ->get();

        $otherTotal = $otherTasks->count();
        $otherDone = $otherTasks->where('status', 'done')->count();

        $progress->push([
            'title' => 'Lainnya',
            'done' => $otherDone,
            'total' => $otherTotal,
            'percent' => $otherTotal > 0 ? (int) round(($otherDone / $otherTotal) * 100) : 0,
        ]);

        return $progress;
    }

    private function eventTimeLabel(?object $event): ?string
    {
        if (! $event?->waktu_mulai) {
            return null;
        }

        $start = substr((string) $event->waktu_mulai, 0, 5);
        $start = str_replace(':', '.', $start).' WIB';

        if ($event->jam_selesai) {
            $end = substr((string) $event->jam_selesai, 0, 5);
            $end = str_replace(':', '.', $end).' WIB';

            return "{$start} - {$end}";
        }

        return "{$start} - Selesai";
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
