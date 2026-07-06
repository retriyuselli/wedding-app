<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VendorPackageResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'price' => $this->price,
            'price_type' => $this->price_type?->value,
            'price_type_label' => $this->price_type?->label(),
            'capacity_min' => $this->capacity_min,
            'capacity_max' => $this->capacity_max,
            'duration_hours' => $this->duration_hours,
            'inclusions' => $this->flattenedInclusions(),
            'facility_sections' => $this->facility_sections ?? [],
            'exclusions' => $this->exclusions ?? [],
            'cover_image' => $this->cover_image,
            'cover_image_url' => $this->cover_image ? asset('storage/'.$this->cover_image) : null,
            'is_featured' => $this->is_featured,
            'sort_order' => $this->sort_order,
        ];
    }
}
