<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'avatar_url' => $this->avatarUrl(),
            'whatsapp' => $this->whatsapp,
            'notification_settings' => $this->notification_settings,
            'has_social_login' => $this->usesSocialLogin(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
