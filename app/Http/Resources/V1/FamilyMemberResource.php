<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FamilyMemberResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'                   => $this->id,
            'no'                   => $this->no,
            'name'                 => $this->name,
            'role'                 => $this->role,
            'phone'                => $this->phone,
            'rsvp_status'          => $this->rsvp_status,
            'rsvp_updated_by_name' => $this->rsvp_updated_by_name,
            'rsvp_updated_at'      => $this->rsvp_updated_at,
            'created_at'           => $this->created_at,
            'updated_at'           => $this->updated_at,
        ];
    }
}
