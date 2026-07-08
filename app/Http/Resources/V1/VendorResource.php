<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VendorResource extends JsonResource
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
            'logo' => $this->logo,
            'logo_url' => $this->logo ? asset('storage/'.$this->logo) : null,
            'cover_image' => $this->cover_image,
            'cover_image_url' => $this->cover_image ? asset('storage/'.$this->cover_image) : null,
            'province' => $this->province,
            'city' => $this->city,
            'address' => $this->address,
            'phone' => $this->phone,
            'email' => $this->email,
            'website' => $this->website,
            'instagram' => $this->instagram,
            'is_verified' => $this->is_verified,
            'is_featured' => $this->is_featured,
            'category' => $this->whenLoaded('category', fn () => [
                'id' => $this->category->id,
                'name' => $this->category->name,
                'slug' => $this->category->slug,
                'icon' => $this->category->icon,
            ]),
            'packages_count' => $this->when(
                isset($this->active_packages_count),
                fn () => $this->active_packages_count,
            ),
            'starting_price' => $this->when(
                $this->active_packages_min_price !== null,
                fn () => number_format((float) $this->active_packages_min_price, 2, '.', ''),
            ),
            'packages' => VendorPackageResource::collection($this->whenLoaded('activePackages')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
