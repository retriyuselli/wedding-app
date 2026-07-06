<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        $user = Auth::user();
        $weddingInfo = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        $nextEvent = $events
            ->filter(fn ($e) => $e->tgl_acara?->isFuture())
            ->sortBy('tgl_acara')
            ->first();

        $budget = $user->weddingBudget;
        $totalPaid = $user->paymentSchedules()->where('status', 'paid')->sum('amount');
        $totalBudget = $budget?->total_budget ?? 0;

        $allTasks = $user->preparationSections()->with('tasks')->get()->flatMap(fn ($s) => $s->tasks);
        $totalTasks = $allTasks->count();
        $doneTasks = $allTasks->where('status', 'done')->count();

        return view('dashboard.index', compact(
            'weddingInfo', 'events', 'nextEvent',
            'totalBudget', 'totalPaid', 'totalTasks', 'doneTasks'
        ));
    }
}
