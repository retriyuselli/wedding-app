<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeddingEventResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'                => $this->id,
            'jenis_acara'       => $this->jenis_acara,
            'jenis_label'       => $this->jenis_label,
            'tgl_acara'         => $this->tgl_acara?->toDateString(),
            'lokasi_acara'      => $this->lokasi_acara,
            'vendor_booking_id' => $this->vendor_booking_id,
            'catatan'           => $this->catatan,
            'created_at'        => $this->created_at,
            'updated_at'        => $this->updated_at,
        ];
    }
}
