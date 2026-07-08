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
            'id' => $this->id,
            'jenis_acara' => $this->jenis_acara,
            'jenis_label' => $this->jenis_label,
            'sort_order' => $this->sort_order,
            'tgl_acara' => $this->tgl_acara?->toDateString(),
            'waktu_mulai' => $this->formatTime($this->waktu_mulai),
            'jam_selesai' => $this->formatTime($this->jam_selesai),
            'lokasi_acara' => $this->lokasi_acara,
            'vendor_booking_id' => $this->vendor_booking_id,
            'catatan' => $this->catatan,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

    private function formatTime(mixed $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        if (is_string($value)) {
            return strlen($value) >= 5 ? substr($value, 0, 5) : $value;
        }

        return null;
    }
}
