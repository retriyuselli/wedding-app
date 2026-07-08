<?php

namespace App\Http\Controllers;

use App\Models\CustomerPreparationSection;
use App\Models\CustomerPreparationTask;
use App\Models\WeddingEvent;
use App\Services\CustomerPreparationSummaryCalculator;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class ChecklistController extends Controller
{
    public function index(
        Request $request,
        CustomerPreparationSummaryCalculator $summaryCalculator,
    ): View {
        $user = Auth::user();
        $weddingInfo = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        $category = $request->string('category')->toString() ?: 'all';
        $status = $request->string('status')->toString() ?: null;
        $search = $request->string('q')->trim()->toString();
        $sort = $request->string('sort')->toString() ?: 'due_date';

        $summary = $summaryCalculator->calculate($user);

        $tasksQuery = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->with(['weddingEvent', 'section', 'subTasks']);

        if (in_array($category, ['akad', 'resepsi', 'pengajian'], true)) {
            $tasksQuery->whereHas('weddingEvent', fn ($query) => $query->where('jenis_acara', $category));
        } elseif ($category === 'lainnya') {
            $tasksQuery->where(function ($query): void {
                $query->whereNull('wedding_event_id')
                    ->orWhereHas('weddingEvent', fn ($eventQuery) => $eventQuery->whereNotIn('jenis_acara', ['akad', 'resepsi', 'pengajian']));
            });
        }

        if (in_array($status, ['done', 'in_progress', 'pending'], true)) {
            $tasksQuery->where('status', $status);
        }

        if ($search !== '') {
            $tasksQuery->where(function ($query) use ($search): void {
                $query->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('label', 'like', "%{$search}%");
            });
        }

        match ($sort) {
            'title' => $tasksQuery->orderBy('title'),
            'status' => $tasksQuery->orderByRaw("field(status, 'pending', 'in_progress', 'done')"),
            default => $tasksQuery->orderByRaw('due_date is null')->orderBy('due_date'),
        };

        $tasks = $tasksQuery->paginate(7)->withQueryString();

        $eventProgress = $this->eventProgress($user->id);

        $upcomingTasksQuery = CustomerPreparationTask::query()
            ->where('user_id', $user->id)
            ->whereIn('status', ['pending', 'in_progress'])
            ->whereNotNull('due_date')
            ->with('weddingEvent');

        if (in_array($category, ['akad', 'resepsi', 'pengajian'], true)) {
            $upcomingTasksQuery->whereHas('weddingEvent', fn ($query) => $query->where('jenis_acara', $category));
        } elseif ($category === 'lainnya') {
            $upcomingTasksQuery->where(function ($query): void {
                $query->whereNull('wedding_event_id')
                    ->orWhereHas('weddingEvent', fn ($eventQuery) => $eventQuery->whereNotIn('jenis_acara', ['akad', 'resepsi', 'pengajian']));
            });
        }

        $upcomingTasks = $upcomingTasksQuery
            ->orderBy('due_date')
            ->limit(3)
            ->get();

        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->sortByDesc('tgl_acara')->first();

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        $categories = [
            ['key' => 'all', 'label' => 'Semua'],
            ['key' => 'akad', 'label' => 'Akad Nikah'],
            ['key' => 'resepsi', 'label' => 'Resepsi'],
            ['key' => 'pengajian', 'label' => 'Pengajian'],
            ['key' => 'lainnya', 'label' => 'Lainnya'],
        ];

        $sortOptions = [
            'due_date' => 'Batas Waktu',
            'title' => 'Nama Tugas',
            'status' => 'Status',
        ];

        return view('checklist.index', [
            'events' => $events,
            'mainEvent' => $mainEvent,
            'tasks' => $tasks,
            'summary' => $summary,
            'eventProgress' => $eventProgress,
            'upcomingTasks' => $upcomingTasks,
            'categories' => $categories,
            'sortOptions' => $sortOptions,
            'activeCategory' => $category,
            'activeStatus' => $status,
            'activeSort' => $sort,
            'search' => $search,
            'coupleLabel' => $this->coupleLabel($weddingInfo, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d M Y'),
            'unreadNotifications' => $unreadNotifications,
        ]);
    }

    // ─── Tasks ───────────────────────────────────────────────────────────

    public function createTask(Request $request): View
    {
        $events = Auth::user()->weddingEvents()->get();
        $sections = CustomerPreparationSection::where('user_id', Auth::id())->orderBy('sort_order')->get();
        $eventId = $request->get('event');
        $sectionId = $request->get('section');

        return view('checklist.task-create', compact('events', 'sections', 'eventId', 'sectionId'));
    }

    public function storeTask(Request $request): RedirectResponse
    {
        $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'due_date' => ['nullable', 'date'],
        ]);

        CustomerPreparationTask::create([
            'user_id' => Auth::id(),
            'title' => $request->title,
            'due_date' => $request->due_date ?: null,
            'section_id' => $request->section_id ?: null,
            'wedding_event_id' => $request->event_id ?: null,
            'status' => 'pending',
        ]);

        return redirect()->route('checklist', ['event' => $request->event_id])
            ->with('success', 'Task berhasil ditambahkan.');
    }

    public function editTask(int $id): View
    {
        $task = CustomerPreparationTask::where('user_id', Auth::id())->findOrFail($id);
        $events = Auth::user()->weddingEvents()->get();
        $sections = CustomerPreparationSection::where('user_id', Auth::id())->orderBy('sort_order')->get();

        return view('checklist.task-edit', compact('task', 'events', 'sections'));
    }

    public function updateTask(Request $request, int $id): RedirectResponse
    {
        $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'due_date' => ['nullable', 'date'],
        ]);

        CustomerPreparationTask::where('user_id', Auth::id())->findOrFail($id)->update([
            'title' => $request->title,
            'due_date' => $request->due_date ?: null,
            'section_id' => $request->section_id ?: null,
            'wedding_event_id' => $request->event_id ?: null,
        ]);

        return redirect()->route('checklist', ['event' => $request->event_id])
            ->with('success', 'Task berhasil diperbarui.');
    }

    public function destroyTask(int $id): RedirectResponse
    {
        $task = CustomerPreparationTask::where('user_id', Auth::id())->findOrFail($id);
        $eventId = $task->wedding_event_id;
        $task->delete();

        return redirect()->route('checklist', ['event' => $eventId])
            ->with('success', 'Task berhasil dihapus.');
    }

    public function toggleTask(int $id): RedirectResponse
    {
        $task = CustomerPreparationTask::where('user_id', Auth::id())->findOrFail($id);
        $task->status = $task->status === 'done' ? 'pending' : 'done';
        $task->save();

        return back();
    }

    // ─── Sections ─────────────────────────────────────────────────────────

    public function createSection(Request $request): View
    {
        $eventId = $request->get('event');

        return view('checklist.section-create', compact('eventId'));
    }

    public function storeSection(Request $request): RedirectResponse
    {
        $request->validate(['title' => ['required', 'string', 'max:255']]);

        CustomerPreparationSection::create([
            'user_id' => Auth::id(),
            'title' => $request->title,
        ]);

        return redirect()->route('checklist', ['event' => $request->event_id])
            ->with('success', 'Section berhasil ditambahkan.');
    }

    public function editSection(int $id): View
    {
        $section = CustomerPreparationSection::where('user_id', Auth::id())->findOrFail($id);

        return view('checklist.section-edit', compact('section'));
    }

    public function updateSection(Request $request, int $id): RedirectResponse
    {
        $request->validate(['title' => ['required', 'string', 'max:255']]);

        CustomerPreparationSection::where('user_id', Auth::id())->findOrFail($id)
            ->update(['title' => $request->title]);

        return redirect()->route('checklist', ['event' => $request->event_id])
            ->with('success', 'Section berhasil diperbarui.');
    }

    public function destroySection(int $id): RedirectResponse
    {
        CustomerPreparationSection::where('user_id', Auth::id())->findOrFail($id)->delete();

        return redirect()->route('checklist')->with('success', 'Section berhasil dihapus.');
    }

    // ─── Events ───────────────────────────────────────────────────────────

    public function createEvent(): View
    {
        return view('checklist.event-create');
    }

    public function storeEvent(Request $request): RedirectResponse
    {
        $request->validate([
            'jenis_acara' => ['required', 'in:lamaran,pengajian,akad,resepsi'],
            'tgl_acara' => ['nullable', 'date'],
            'lokasi_acara' => ['nullable', 'string', 'max:255'],
        ]);

        $event = WeddingEvent::create([
            'user_id' => Auth::id(),
            'jenis_acara' => $request->jenis_acara,
            'tgl_acara' => $request->tgl_acara ?: null,
            'lokasi_acara' => $request->lokasi_acara ?: null,
            'catatan' => $request->catatan ?: null,
        ]);

        return redirect()->route('checklist', ['event' => $event->id])
            ->with('success', 'Acara berhasil ditambahkan.');
    }

    public function editEvent(int $id): View
    {
        $event = WeddingEvent::where('user_id', Auth::id())->findOrFail($id);

        return view('checklist.event-edit', compact('event'));
    }

    public function updateEvent(Request $request, int $id): RedirectResponse
    {
        $request->validate([
            'jenis_acara' => ['required', 'in:lamaran,pengajian,akad,resepsi'],
            'tgl_acara' => ['nullable', 'date'],
            'lokasi_acara' => ['nullable', 'string', 'max:255'],
        ]);

        WeddingEvent::where('user_id', Auth::id())->findOrFail($id)->update([
            'jenis_acara' => $request->jenis_acara,
            'tgl_acara' => $request->tgl_acara ?: null,
            'lokasi_acara' => $request->lokasi_acara ?: null,
            'catatan' => $request->catatan ?: null,
        ]);

        return redirect()->route('checklist', ['event' => $id])
            ->with('success', 'Acara berhasil diperbarui.');
    }

    public function destroyEvent(int $id): RedirectResponse
    {
        WeddingEvent::where('user_id', Auth::id())->findOrFail($id)->delete();

        return redirect()->route('checklist')->with('success', 'Acara berhasil dihapus.');
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

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
