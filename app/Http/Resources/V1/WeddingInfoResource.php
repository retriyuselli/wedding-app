<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeddingInfoResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        if ($this->resource === null) {
            return [
                'id' => null,
                'groom_name' => null,
                'bride_name' => null,
                'budaya' => null,
                'songlist' => [],
                'avatar_url' => $request->user()->avatarUrl(),
                'created_at' => null,
                'updated_at' => null,
            ];
        }

        return [
            'id' => $this->id,
            'groom_name' => $this->groom_name,
            'bride_name' => $this->bride_name,
            'budaya' => $this->budaya,
            'songlist' => $this->songlist,
            'avatar_url' => $request->user()->avatarUrl(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
