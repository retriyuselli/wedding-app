<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\SupportMessageTopic;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\MessageResource;
use App\Http\Resources\V1\MessageThreadResource;
use App\Models\Message;
use App\Models\MessageThread;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Validation\Rule;

class MessageController extends Controller
{
    public function threads(Request $request): AnonymousResourceCollection
    {
        $query = MessageThread::query()
            ->where('user_id', $request->user()->id)
            ->withCount([
                'messages as unread_count' => fn ($query) => $query
                    ->where('is_outgoing', false)
                    ->whereNull('read_at'),
            ])
            ->with('latestMessage')
            ->latest('updated_at');

        if ($request->filled('category') && $request->string('category')->toString() !== 'all') {
            $query->where('category', $request->string('category')->toString());
        }

        if ($request->boolean('unread_only')) {
            $query->whereHas('messages', fn ($query) => $query
                ->where('is_outgoing', false)
                ->whereNull('read_at'));
        }

        return MessageThreadResource::collection($query->get());
    }

    public function supportThread(Request $request): JsonResponse
    {
        $user = $request->user();

        $thread = MessageThread::query()
            ->where('user_id', $user->id)
            ->where('category', 'support')
            ->first();

        if (! $thread) {
            $thread = MessageThread::create([
                'user_id' => $user->id,
                'name' => 'Support Wedding App',
                'category' => 'support',
                'is_online' => true,
            ]);
        }

        $thread->loadCount([
            'messages as unread_count' => fn ($query) => $query
                ->where('is_outgoing', false)
                ->whereNull('read_at'),
        ])->load('latestMessage');

        return response()->json([
            'data' => new MessageThreadResource($thread),
        ]);
    }

    public function show(Request $request, int $thread): MessageThreadResource
    {
        $messageThread = $this->findOwnedThread($request, $thread);

        Message::query()
            ->where('message_thread_id', $messageThread->id)
            ->where('user_id', $request->user()->id)
            ->where('is_outgoing', false)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return new MessageThreadResource(
            $messageThread->load(['messages' => fn ($query) => $query->orderBy('created_at')])
        );
    }

    public function send(Request $request, int $thread): JsonResponse
    {
        $messageThread = $this->findOwnedThread($request, $thread);

        $rules = [
            'body' => ['required', 'string', 'max:5000'],
        ];

        if ($messageThread->category === 'support') {
            $rules['topic'] = ['nullable', 'string', Rule::enum(SupportMessageTopic::class)];
        }

        $data = $request->validate($rules);

        $message = $messageThread->messages()->create([
            'user_id' => $request->user()->id,
            'body' => $data['body'],
            'topic' => $data['topic'] ?? null,
            'is_outgoing' => true,
            'read_at' => now(),
        ]);

        $messageThread->touch();

        return response()->json([
            'data' => new MessageResource($message),
        ], 201);
    }

    public function destroy(Request $request, int $thread): Response
    {
        $this->findOwnedThread($request, $thread)->delete();

        return response()->noContent();
    }

    private function findOwnedThread(Request $request, int $id): MessageThread
    {
        return MessageThread::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }
}
