<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GuestResource extends JsonResource
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
            'name'                 => $this->name,
            'phone'                => $this->phone,
            'email'                => $this->email,
            'table_number'         => $this->table_number,
            'rsvp_status'          => $this->rsvp_status,
            'rsvp_updated_by_name' => $this->rsvp_updated_by_name,
            'rsvp_updated_at'      => $this->rsvp_updated_at,
            'catatan'              => $this->catatan,
            'created_at'           => $this->created_at,
            'updated_at'           => $this->updated_at,
        ];
    }
}
