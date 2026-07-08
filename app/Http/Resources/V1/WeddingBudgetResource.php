<?php

namespace App\Http\Resources\V1;

use App\Models\WeddingBudget;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeddingBudgetResource extends JsonResource
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
                'total_budget' => 0,
                'currency' => WeddingBudget::defaultCurrency(),
                'notes' => null,
                'created_at' => null,
                'updated_at' => null,
            ];
        }

        return [
            'id' => $this->id,
            'total_budget' => (float) ($this->total_budget ?? 0),
            'currency' => $this->currency ?? WeddingBudget::defaultCurrency(),
            'notes' => $this->notes,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
