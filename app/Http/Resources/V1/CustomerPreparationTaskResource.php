<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerPreparationTaskResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'wedding_event_id' => $this->wedding_event_id,
            'section_id'       => $this->section_id,
            'title'            => $this->title,
            'label'            => $this->label,
            'description'      => $this->description,
            'notes'            => $this->notes,
            'priority'         => $this->priority,
            'status'           => $this->status,
            'due_date'         => $this->due_date?->toDateString(),
            'sort_order'       => $this->sort_order,
            'sub_tasks'        => CustomerPreparationSubTaskResource::collection($this->whenLoaded('subTasks')),
            'attachments'      => CustomerPreparationTaskAttachmentResource::collection($this->whenLoaded('attachments')),
            'created_at'       => $this->created_at,
            'updated_at'       => $this->updated_at,
        ];
    }
}
