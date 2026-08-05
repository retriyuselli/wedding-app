<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerNotificationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'          => $this->id,
            'group'       => $this->group,
            'title'       => $this->title,
            'message'     => $this->message,
            'icon'        => $this->icon,
            'destination' => $this->destination,
            'tint'        => $this->tint,
            'is_unread'   => $this->is_unread,
            'created_at'  => $this->created_at,
            'updated_at'  => $this->updated_at,
        ];
    }
}
