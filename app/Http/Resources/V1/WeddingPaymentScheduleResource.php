<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeddingPaymentScheduleResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'                         => $this->id,
            'wedding_event_id'           => $this->wedding_event_id !== null ? (int) $this->wedding_event_id : null,
            'customer_payment_method_id' => $this->customer_payment_method_id !== null ? (int) $this->customer_payment_method_id : null,
            'title'                      => $this->title,
            'vendor_name'                => $this->vendor_name,
            'category'                   => $this->category,
            'category_label'             => $this->category_label,
            'amount'                     => (float) $this->amount,
            'due_date'                   => $this->due_date?->toDateString(),
            'status'                     => $this->status,
            'paid_at'                    => $this->paid_at,
            'proof_url'                  => $this->proofUrl(),
            'notes'                      => $this->notes,
            'sort_order'                 => (int) $this->sort_order,
            'created_at'                 => $this->created_at,
            'updated_at'                 => $this->updated_at,
        ];
    }
}
