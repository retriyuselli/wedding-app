<?php

namespace App\Http\Resources\V1;

use App\Models\WeddingIncomingPayment;
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
        $status = $this->status ?? config('wedding.default_incoming_payment_status', 'menunggu');

        return [
            'id' => $this->id,
            'bank_name' => $this->bank_name,
            'amount' => (float) $this->amount,
            'transfer_date' => $this->transfer_date?->toDateString(),
            'sender_name' => $this->sender_name,
            'description' => $this->description,
            'reference_number' => $this->reference_number,
            'proof_url' => $this->proof_url,
            'status' => $status,
            'status_label' => $this->status
                ? $this->status_label
                : (WeddingIncomingPayment::$statusOptions[$status] ?? 'Menunggu'),
            'confirmed_at' => $this->confirmed_at,
            'confirmed_by' => $this->confirmed_by,
            'rejection_reason' => $this->rejection_reason,
            'notes' => $this->notes,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
