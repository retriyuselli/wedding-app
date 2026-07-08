<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Laravel\Sanctum\PersonalAccessToken;

/** @mixin PersonalAccessToken */
class ActiveSessionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'device_name' => $this->name,
            'last_used_at' => $this->last_used_at,
            'created_at' => $this->created_at,
            'is_current' => (bool) ($this->is_current ?? false),
        ];
    }
}
