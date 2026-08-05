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
        $startingPrice = $this->resolveStartingPrice();

        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'logo' => $this->logo,
            'logo_url' => $this->logoUrl(),
            'cover_image' => is_array($this->cover_image) ? ($this->cover_image[0] ?? null) : $this->cover_image,
            'cover_image_url' => $this->resolvedCoverUrl(),
            'province' => $this->province,
            'city' => $this->city,
            'address' => $this->address,
            'phone' => $this->phone,
            'email' => $this->email,
            'website' => $this->website,
            'instagram' => $this->instagram,
            'is_verified' => (bool) $this->is_verified,
            'is_featured' => (bool) $this->is_featured,
            'category' => ($category = $this->resolveCategory()) ? [
                'id' => $category->id,
                'name' => $category->name,
                'slug' => $category->slug,
                'icon' => $category->icon ?? null,
            ] : null,
            'packages_count' => $this->when(
                isset($this->active_packages_count),
                fn () => $this->active_packages_count,
            ),
            'starting_price' => $this->when(
                $startingPrice !== null,
                fn () => number_format((float) $startingPrice, 2, '.', ''),
            ),
            'packages' => VendorPackageResource::collection($this->whenLoaded('activePackages')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

    private function resolveCategory(): mixed
    {
        if ($this->relationLoaded('categoryVendor')) {
            return $this->categoryVendor;
        }

        if ($this->relationLoaded('category')) {
            return $this->category;
        }

        if (method_exists($this->resource, 'categoryVendor')) {
            return $this->resource->categoryVendor;
        }

        return $this->category;
    }

    private function resolveStartingPrice(): ?float
    {
        if ($this->active_packages_min_price !== null) {
            return (float) $this->active_packages_min_price;
        }

        if (isset($this->attributes['price_start']) || isset($this->price_start)) {
            $priceStart = $this->price_start ?? null;
            if ($priceStart !== null) {
                return max(0, (float) $priceStart - (float) ($this->discount ?? 0));
            }
        }

        return null;
    }
}
