<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerPreparationTaskAttachmentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'         => $this->id,
            'file_name'  => $this->file_name,
            'file_path'  => $this->file_path,
            'file_size'  => $this->file_size,
            'mime_type'  => $this->mime_type,
            'url'        => $this->url,
            'created_at' => $this->created_at,
        ];
    }
}
