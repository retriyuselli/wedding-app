<?php

namespace App\Http\Controllers;

use App\Models\CustomerPreparationTask;
use App\Models\WeddingEvent;
use App\Services\CustomerPreparationSummaryCalculator;
use App\Services\WeddingBudgetSummaryCalculator;
use App\Support\VendorCatalog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class ProfilController extends Controller
{
    public function index(
        CustomerPreparationSummaryCalculator $checklistCalculator,
        WeddingBudgetSummaryCalculator $budgetCalculator,
    ): View {
        $user = Auth::user();
        $info = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->filter(fn ($event) => $event->tgl_acara?->isFuture())->sortBy('tgl_acara')->first()
            ?? $events->sortByDesc('tgl_acara')->first();

        $checklistSummary = $checklistCalculator->calculate($user);
        $budgetSummary = $budgetCalculator->calculate($user);

        $allGuests = collect()
            ->merge($user->guests()->get(['rsvp_status']))
            ->merge($user->familyMembers()->get(['rsvp_status']))
            ->merge($user->vipGuests()->get(['rsvp_status']));

        $totalGuests = $allGuests->count();
        $confirmedGuests = $allGuests->where('rsvp_status', 'hadir')->count();

        $vendorThreads = $user->messageThreads()
            ->where('category', 'vendor')
            ->with('latestMessage')
            ->withCount('messages')
            ->latest('updated_at')
            ->get();

        $totalVendors = $vendorThreads->count();
        $confirmedVendors = $vendorThreads
            ->filter(fn ($thread) => $thread->messages_count >= 2)
            ->count();

        if ($totalVendors === 0) {
            $totalVendors = VendorCatalog::query()->where('is_active', true)->count();
            $confirmedVendors = (int) round($totalVendors * 0.67);
        }

        $upcomingTasks = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->whereIn('status', ['pending', 'in_progress'])
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(4)
            ->get();

        $recentVendors = $vendorThreads->isNotEmpty()
            ? $vendorThreads->take(4)
            : (VendorCatalog::usingPaket()
                ? VendorCatalog::queryWithCategory()->where('is_active', true)->orderByDesc('likes')->limit(4)->get()
                : VendorCatalog::queryWithCategory()->where('is_active', true)->orderBy('sort_order')->limit(4)->get());

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        $coupleLabel = $this->coupleLabel($info, $user->name);
        $weddingDateLabel = $mainEvent?->tgl_acara?->translatedFormat('d F Y');
        $mainLocation = $mainEvent?->lokasi_acara;
        $eventTypesLabel = $this->eventTypesLabel($events);

        return view('profil.index', [
            'user' => $user,
            'info' => $info,
            'coupleLabel' => $coupleLabel,
            'weddingDateLabel' => $weddingDateLabel,
            'mainLocation' => $mainLocation,
            'eventTypesLabel' => $eventTypesLabel,
            'checklistSummary' => $checklistSummary,
            'budgetSummary' => $budgetSummary,
            'guestStats' => [
                'total' => $totalGuests,
                'confirmed' => $confirmedGuests,
            ],
            'vendorStats' => [
                'total' => $totalVendors,
                'confirmed' => $confirmedVendors,
            ],
            'upcomingTasks' => $upcomingTasks,
            'recentVendors' => $recentVendors,
            'unreadNotifications' => $unreadNotifications,
        ]);
    }

    public function updateProfile(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email,'.Auth::id()],
            'whatsapp' => ['nullable', 'string', 'max:20'],
        ]);

        Auth::user()->update([
            'name' => $request->name,
            'email' => $request->email,
            'whatsapp' => $request->whatsapp ?: null,
        ]);

        return back()->with('success_profile', 'Profil berhasil disimpan.');
    }

    public function updateWeddingInfo(Request $request): RedirectResponse
    {
        $request->validate([
            'groom_name' => ['nullable', 'string', 'max:255'],
            'bride_name' => ['nullable', 'string', 'max:255'],
            'budaya' => ['nullable', 'string', 'max:100'],
        ]);

        Auth::user()->weddingInfo()->updateOrCreate(
            ['user_id' => Auth::id()],
            [
                'groom_name' => $request->groom_name ?: null,
                'bride_name' => $request->bride_name ?: null,
                'budaya' => $request->budaya ?: null,
            ]
        );

        return back()->with('success_wedding', 'Info pernikahan berhasil disimpan.');
    }

    public function updatePassword(Request $request): RedirectResponse
    {
        $request->validate([
            'current_password' => ['required'],
            'new_password' => ['required', 'min:8', 'confirmed'],
        ], [], [
            'current_password' => 'password saat ini',
            'new_password' => 'password baru',
        ]);

        if (! Hash::check($request->current_password, Auth::user()->password)) {
            return back()->withErrors(['current_password' => 'Password saat ini tidak sesuai.']);
        }

        Auth::user()->update(['password' => Hash::make($request->new_password)]);

        return back()->with('success_password', 'Password berhasil diubah.');
    }

    /**
     * @return array{label: string, class: string}
     */
    public static function taskBadge(CustomerPreparationTask $task): array
    {
        if ($task->status === 'in_progress') {
            return ['label' => 'Dalam Proses', 'class' => 'bg-amber-50 text-amber-700'];
        }

        if ($task->due_date?->isFuture()) {
            return ['label' => 'Akan Datang', 'class' => 'bg-sky-50 text-sky-700'];
        }

        return ['label' => 'Belum Mulai', 'class' => 'bg-gray-100 text-gray-600'];
    }

    /**
     * @param  Collection<int, WeddingEvent>|\Illuminate\Database\Eloquent\Collection<int, WeddingEvent>  $events
     */
    private function eventTypesLabel(Collection $events): string
    {
        $labels = $events
            ->map(fn ($event) => $event->jenis_label)
            ->unique()
            ->values();

        if ($labels->isEmpty()) {
            return 'Akad & Resepsi';
        }

        return $labels->take(2)->implode(' & ');
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
