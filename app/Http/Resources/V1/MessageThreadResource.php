<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MessageThreadResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $latestMessage = $this->relationLoaded('latestMessage')
            ? $this->latestMessage
            : ($this->relationLoaded('messages')
                ? $this->messages->sortByDesc('id')->first()
                : null);

        $unreadCount = (int) ($this->unread_count ?? 0);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'category' => $this->category,
            'avatar_url' => $this->avatar_url,
            'is_online' => $this->is_online,
            'last_message' => $latestMessage?->body,
            'last_message_at' => $latestMessage?->created_at,
            'unread_count' => $unreadCount,
            'has_unread' => $unreadCount > 0,
            'messages' => MessageResource::collection($this->whenLoaded('messages')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
