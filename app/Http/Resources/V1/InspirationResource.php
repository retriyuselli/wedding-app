<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InspirationResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'category' => $this->category,
            'image_url' => $this->resolveImageUrl(),
            'thumbnail_symbol' => $this->thumbnail_symbol,
            'likes' => $this->likes_count,
            'views' => $this->views_count,
            'is_saved' => (bool) ($this->is_saved ?? false),
            'is_liked' => (bool) ($this->is_liked ?? false),
            'sort_order' => $this->sort_order,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

    private function resolveImageUrl(): ?string
    {
        $imageUrl = $this->image_url;

        if (blank($imageUrl)) {
            return null;
        }

        if (str_starts_with($imageUrl, 'http://') || str_starts_with($imageUrl, 'https://')) {
            return $imageUrl;
        }

        return asset('storage/'.$imageUrl);
    }
}
