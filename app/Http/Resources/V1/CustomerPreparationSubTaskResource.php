<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerPreparationSubTaskResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'title'        => $this->title,
            'status'       => $this->status,
            'due_date'     => $this->due_date?->toDateString(),
            'completed_at' => $this->completed_at?->toDateString(),
            'sort_order'   => $this->sort_order,
        ];
    }
}
