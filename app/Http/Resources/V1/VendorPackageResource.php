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
        $price = $this->resource->getAttribute('final_price')
            ?? $this->price;

        $coverUrl = method_exists($this->resource, 'coverImageUrl')
            ? $this->resource->coverImageUrl()
            : ($this->cover_image ? asset('storage/'.$this->cover_image) : null);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'price' => $price,
            'price_type' => $this->price_type?->value,
            'price_type_label' => $this->price_type?->label(),
            'capacity_min' => $this->capacity_min,
            'capacity_max' => $this->capacity_max,
            'duration_hours' => $this->duration_hours,
            'inclusions' => $this->flattenedInclusions(),
            'facility_sections' => $this->facility_sections ?? [],
            // Raw Filament RichEditor HTML — iOS renders this to match paketpernikahan.co.id
            'item_html' => $this->resolveItemHtml(),
            'exclusions' => $this->exclusions ?? [],
            'cover_image' => $this->cover_image,
            'cover_image_url' => $coverUrl,
            'is_featured' => (bool) $this->is_featured,
            'sort_order' => $this->sort_order,
        ];
    }

    private function resolveItemHtml(): ?string
    {
        if (method_exists($this->resource, 'itemHtml')) {
            $html = $this->resource->itemHtml();
            if (is_string($html) && trim($html) !== '') {
                return $html;
            }
        }

        $attributeHtml = $this->resource->getAttribute('item_html')
            ?? $this->resource->getAttributes()['item']
            ?? null;

        if (is_string($attributeHtml) && trim($attributeHtml) !== '') {
            return $attributeHtml;
        }

        // Build simple HTML from structured sections (local wedding-app packages).
        $sections = $this->facility_sections ?? [];
        if (! is_array($sections) || $sections === []) {
            return null;
        }

        $parts = [];
        foreach ($sections as $section) {
            $title = trim((string) ($section['title'] ?? ''));
            $items = array_values(array_filter(array_map(
                fn ($item): string => trim((string) $item),
                $section['items'] ?? [],
            )));

            if ($title !== '' && strcasecmp($title, 'Fasilitas') !== 0) {
                $parts[] = '<p><strong>'.e($title).'</strong></p>';
            } elseif ($title !== '') {
                $parts[] = '<p><strong>'.e($title).'</strong></p>';
            }

            if ($items !== []) {
                $lis = implode('', array_map(
                    fn (string $item): string => '<li>'.e($item).'</li>',
                    $items,
                ));
                $parts[] = '<ol>'.$lis.'</ol>';
            }
        }

        $html = implode('', $parts);

        return $html !== '' ? $html : null;
    }
}
