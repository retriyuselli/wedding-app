<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeddingIncomingPaymentResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'bank_name'        => $this->bank_name,
            'amount'           => (float) $this->amount,
            'transfer_date'    => $this->transfer_date?->toDateString(),
            'sender_name'      => $this->sender_name,
            'description'      => $this->description,
            'reference_number' => $this->reference_number,
            'proof_url'        => $this->proof_url,
            'status'           => $this->status,
            'status_label'     => $this->status_label,
            'confirmed_at'     => $this->confirmed_at,
            'confirmed_by'     => $this->confirmed_by,
            'rejection_reason' => $this->rejection_reason,
            'notes'            => $this->notes,
            'created_at'       => $this->created_at,
            'updated_at'       => $this->updated_at,
        ];
    }
}
