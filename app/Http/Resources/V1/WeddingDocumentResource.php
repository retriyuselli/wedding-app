<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeddingDocumentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'document_folder_id' => $this->document_folder_id,
            'folder_name' => $this->whenLoaded('folder', fn () => $this->folder?->name),
            'file_name' => $this->file_name,
            'file_path' => $this->file_path,
            'file_size' => $this->file_size,
            'mime_type' => $this->mime_type,
            'category' => $this->category,
            'url' => $this->absoluteFileUrl($request),
            'source' => $this->source ?? 'uploaded',
            'task_title' => $this->task_title ?? null,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }

    private function absoluteFileUrl(Request $request): ?string
    {
        $path = $this->file_path;

        if (! is_string($path) || $path === '') {
            return null;
        }

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }

        return $request->getSchemeAndHttpHost().'/storage/'.ltrim($path, '/');
    }
}
