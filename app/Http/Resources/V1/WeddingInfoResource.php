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
                'groom_full_name' => null,
                'groom_phone' => null,
                'groom_father_name' => null,
                'groom_mother_name' => null,
                'bride_name' => null,
                'bride_full_name' => null,
                'bride_phone' => null,
                'bride_father_name' => null,
                'bride_mother_name' => null,
                'budaya' => null,
                'songlist' => [],
                'avatar_url' => $request->user()?->avatarUrl(),
                'couple_photo_url' => null,
                'created_at' => null,
                'updated_at' => null,
            ];
        }

        return [
            'id' => $this->id,
            'groom_name' => $this->groom_name,
            'groom_full_name' => $this->groom_full_name,
            'groom_phone' => $this->groom_phone,
            'groom_father_name' => $this->groom_father_name,
            'groom_mother_name' => $this->groom_mother_name,
            'bride_name' => $this->bride_name,
            'bride_full_name' => $this->bride_full_name,
            'bride_phone' => $this->bride_phone,
            'bride_father_name' => $this->bride_father_name,
            'bride_mother_name' => $this->bride_mother_name,
            'budaya' => $this->budaya,
            'songlist' => $this->songlist,
            'avatar_url' => $request->user()?->avatarUrl(),
            'couple_photo_url' => $this->couplePhotoUrl(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
