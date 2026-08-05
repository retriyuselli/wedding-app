<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\MessageThread;
use App\Models\WeddingEvent;
use App\Models\WeddingInfo;
use App\Support\VendorCatalog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\View\View;

class MessageController extends Controller
{
    public function index(Request $request): View
    {
        $user = $request->user();
        $favoriteIds = $this->favoriteThreadIds($request);
        $tab = $request->string('tab', 'all')->toString();
        $search = trim($request->string('q')->toString());

        $threadsQuery = MessageThread::query()
            ->where('user_id', $user->id)
            ->withCount([
                'messages as unread_count' => fn ($query) => $query
                    ->where('is_outgoing', false)
                    ->whereNull('read_at'),
            ])
            ->with('latestMessage')
            ->latest('updated_at');

        if ($tab === 'unread') {
            $threadsQuery->whereHas('messages', fn ($query) => $query
                ->where('is_outgoing', false)
                ->whereNull('read_at'));
        }

        if ($tab === 'favorite') {
            $threadsQuery->whereIn('id', $favoriteIds ?: [0]);
        }

        if ($search !== '') {
            $threadsQuery->where(function ($query) use ($search): void {
                $query->where('name', 'like', "%{$search}%")
                    ->orWhereHas('messages', fn ($messageQuery) => $messageQuery
                        ->where('body', 'like', "%{$search}%"));
            });
        }

        $threads = $threadsQuery->paginate(8)->withQueryString();

        $totalUnreadThreads = MessageThread::query()
            ->where('user_id', $user->id)
            ->whereHas('messages', fn ($query) => $query
                ->where('is_outgoing', false)
                ->whereNull('read_at'))
            ->count();

        $activeThread = null;
        $messages = collect();
        $vendorProfile = null;
        $sharedAttachments = collect();
        $notes = collect();

        $threadId = null;

        if ($request->boolean('list')) {
            $threadId = null;
        } elseif ($request->filled('thread')) {
            $threadId = $request->integer('thread');
        } elseif ($threads->isNotEmpty()) {
            $threadId = $threads->first()->id;
        }

        if ($threadId) {
            $activeThread = MessageThread::query()
                ->where('user_id', $user->id)
                ->with(['messages' => fn ($query) => $query->orderBy('created_at')])
                ->find($threadId);

            if ($activeThread) {
                Message::query()
                    ->where('message_thread_id', $activeThread->id)
                    ->where('user_id', $user->id)
                    ->where('is_outgoing', false)
                    ->whereNull('read_at')
                    ->update(['read_at' => now()]);

                $messages = $activeThread->messages;
                $vendorProfile = $this->resolveVendorProfile($activeThread);
                $sharedAttachments = $this->sharedAttachments($activeThread);
                $notes = $this->threadNotes($activeThread);
            }
        }

        $weddingInfo = WeddingInfo::query()->where('user_id', $user->id)->first();
        $akadEvent = WeddingEvent::query()
            ->where('user_id', $user->id)
            ->where('jenis_acara', 'akad')
            ->first();

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        return view('messages.index', [
            'threads' => $threads,
            'activeThread' => $activeThread,
            'messages' => $messages,
            'messagesByDate' => $messages->groupBy(fn (Message $message) => $message->created_at->toDateString()),
            'vendorProfile' => $vendorProfile,
            'sharedAttachments' => $sharedAttachments,
            'notes' => $notes,
            'tab' => $tab,
            'search' => $search,
            'favoriteIds' => $favoriteIds,
            'totalUnreadThreads' => $totalUnreadThreads,
            'weddingInfo' => $weddingInfo,
            'akadEvent' => $akadEvent,
            'coupleLabel' => $this->coupleLabel($weddingInfo, $user->name),
            'weddingDateLabel' => $akadEvent?->tgl_acara?->translatedFormat('d M Y'),
            'unreadNotifications' => $unreadNotifications,
        ]);
    }

    public function send(Request $request, MessageThread $thread): RedirectResponse
    {
        abort_unless($thread->user_id === $request->user()->id, 403);

        $data = $request->validate([
            'body' => ['required', 'string', 'max:5000'],
        ]);

        $thread->messages()->create([
            'user_id' => $request->user()->id,
            'body' => $data['body'],
            'is_outgoing' => true,
            'read_at' => now(),
        ]);

        $thread->touch();

        return redirect()->route('messages', [
            'thread' => $thread->id,
            'tab' => $request->input('tab', 'all'),
            'q' => $request->input('q'),
        ]);
    }

    public function toggleFavorite(Request $request, MessageThread $thread): RedirectResponse
    {
        abort_unless($thread->user_id === $request->user()->id, 403);

        $favorites = $this->favoriteThreadIds($request);

        if (in_array($thread->id, $favorites, true)) {
            $favorites = array_values(array_diff($favorites, [$thread->id]));
        } else {
            $favorites[] = $thread->id;
        }

        $request->session()->put('favorite_threads', $favorites);

        return redirect()->route('messages', [
            'thread' => $thread->id,
            'tab' => $request->input('tab', 'all'),
            'q' => $request->input('q'),
        ]);
    }

    /**
     * @return array<int, int>
     */
    private function favoriteThreadIds(Request $request): array
    {
        return array_values(array_map('intval', $request->session()->get('favorite_threads', [])));
    }

    private function resolveVendorProfile(MessageThread $thread): ?Model
    {
        if ($thread->category !== 'vendor') {
            return null;
        }

        return VendorCatalog::query()
            ->with(VendorCatalog::categoryRelation())
            ->where(function ($query) use ($thread): void {
                $query->where('name', 'like', '%'.$thread->name.'%')
                    ->orWhere('name', $thread->name);
            })
            ->first();
    }

    /**
     * @return Collection<int, array{name: string, size: string}>
     */
    private function sharedAttachments(MessageThread $thread): Collection
    {
        if ($thread->category !== 'vendor') {
            return collect();
        }

        return collect([
            ['name' => 'Proposal_'.$thread->name.'.pdf', 'size' => '2.4 MB'],
            ['name' => 'Kontrak_Vendor.pdf', 'size' => '1.1 MB'],
        ]);
    }

    /**
     * @return Collection<int, array{date: string, author: string, body: string}>
     */
    private function threadNotes(MessageThread $thread): Collection
    {
        if ($thread->category !== 'vendor') {
            return collect();
        }

        return collect([
            [
                'date' => '07 Mei 2024',
                'author' => 'Oleh Anda',
                'body' => 'Vendor responsif dan profesional. Perlu follow up soal tambahan bunga.',
            ],
            [
                'date' => '28 Apr 2024',
                'author' => 'Oleh Anda',
                'body' => 'Sudah diskusi konsep dekorasi utama — tema sage green & putih.',
            ],
        ]);
    }

    public static function formatThreadTime(?Carbon $date): string
    {
        if (! $date) {
            return '';
        }

        if ($date->isToday()) {
            return $date->format('H:i');
        }

        if ($date->isYesterday()) {
            return 'Kemarin';
        }

        return $date->translatedFormat('d M');
    }

    public static function formatMessageTime(Carbon $date): string
    {
        return $date->format('H:i');
    }

    public static function formatDateSeparator(Carbon $date): string
    {
        if ($date->isToday()) {
            return 'Hari ini';
        }

        if ($date->isYesterday()) {
            return 'Kemarin';
        }

        return $date->translatedFormat('d F Y');
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
