<?php

namespace App\Http\Controllers;

use App\Models\CustomerPreparationSection;
use App\Models\CustomerPreparationTask;
use App\Models\WeddingEvent;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class ChecklistController extends Controller
{
    public function index(Request $request): View
    {
        $user = Auth::user();
        $events = $user->weddingEvents()->get();
        $eventId = $request->get('event');

        $current = $eventId
            ? $events->firstWhere('id', $eventId)
            : $events->first();

        $sections = $user->preparationSections()
            ->with(['tasks' => fn ($q) => $q->when(
                $current,
                fn ($q) => $q->where('wedding_event_id', $current->id)->orWhereNull('wedding_event_id')
            )->orderBy('sort_order')])
            ->get();

        $looseTasksQuery = CustomerPreparationTask::where('user_id', Auth::id())
            ->whereNull('section_id')
            ->orderBy('sort_order');

        if ($current) {
            $looseTasksQuery->where(fn ($q) => $q
                ->where('wedding_event_id', $current->id)
                ->orWhereNull('wedding_event_id')
            );
        }

        $looseTasks = $looseTasksQuery->get();
        $allTasks = $sections->flatMap(fn ($s) => $s->tasks)->merge($looseTasks);
        $doneCount = $allTasks->where('status', 'done')->count();
        $total = $allTasks->count();

        return view('checklist.index', compact('events', 'current', 'sections', 'looseTasks', 'doneCount', 'total'));
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
}
