<?php

namespace App\Support;

use App\Models\Paket\Vendor as PaketVendor;
use App\Models\Vendor;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class VendorCatalog
{
    public static function usingPaket(): bool
    {
        return config('wedding.vendors.source') === 'paket';
    }

    /**
     * @return class-string<Model>
     */
    public static function modelClass(): string
    {
        return static::usingPaket() ? PaketVendor::class : Vendor::class;
    }

    public static function categoryRelation(): string
    {
        return static::usingPaket() ? 'categoryVendor' : 'category';
    }

    public static function query(): Builder
    {
        /** @var class-string<Model> $class */
        $class = static::modelClass();

        return $class::query();
    }

    public static function queryWithCategory(): Builder
    {
        return static::query()->with(static::categoryRelation());
    }

    /**
     * @param  list<string>  $slugs
     */
    public static function applyCategorySlugs(Builder $query, array $slugs): Builder
    {
        if ($slugs === []) {
            return $query;
        }

        if (static::usingPaket()) {
            /** @var Builder<PaketVendor> $query */
            return $query->whereCategorySlugs($slugs);
        }

        return $query->whereHas('category', fn ($categoryQuery) => $categoryQuery->whereIn('slug', $slugs));
    }

    /**
     * @return list<array{key: string, label: string, slugs: list<string>}>
     */
    public static function categoryTabs(): array
    {
        if (static::usingPaket()) {
            return [
                ['key' => 'all', 'label' => 'Semua', 'slugs' => []],
                ['key' => 'venue', 'label' => 'Venue', 'slugs' => ['gedung', 'hotel', 'rumah']],
                ['key' => 'catering', 'label' => 'Catering', 'slugs' => ['catering']],
                ['key' => 'dekorasi', 'label' => 'Dekorasi', 'slugs' => ['dekorasi']],
                ['key' => 'foto-video', 'label' => 'Fotografi & Video', 'slugs' => ['foto-video', 'fotobooth']],
                ['key' => 'mua', 'label' => 'MUA', 'slugs' => ['makeup']],
                ['key' => 'busana', 'label' => 'Busana', 'slugs' => ['gaun']],
                ['key' => 'entertainment', 'label' => 'Entertainment', 'slugs' => ['hiburan', 'mc', 'sound-system', 'lighting']],
                ['key' => 'souvenir', 'label' => 'Souvenir', 'slugs' => ['undangan', 'kue-pengantin']],
                ['key' => 'lainnya', 'label' => 'Lainnya', 'slugs' => ['paket-lengkap', 'wo', 'wedding-organizer', 'transportasi', 'perhiasan', 'honeymoon', 'tenda-kursi']],
            ];
        }

        return [
            ['key' => 'all', 'label' => 'Semua', 'slugs' => []],
            ['key' => 'venue', 'label' => 'Venue', 'slugs' => ['venue']],
            ['key' => 'catering', 'label' => 'Catering', 'slugs' => ['catering']],
            ['key' => 'dekorasi', 'label' => 'Dekorasi', 'slugs' => ['dekorasi', 'florist']],
            ['key' => 'foto-video', 'label' => 'Fotografi & Video', 'slugs' => ['fotografi', 'videografi', 'prewedding', 'photo-booth']],
            ['key' => 'mua', 'label' => 'MUA', 'slugs' => ['mua']],
            ['key' => 'busana', 'label' => 'Busana', 'slugs' => ['busana']],
            ['key' => 'entertainment', 'label' => 'Entertainment', 'slugs' => ['entertainment', 'mc', 'sound-lighting']],
            ['key' => 'souvenir', 'label' => 'Souvenir', 'slugs' => ['souvenir', 'undangan', 'kue']],
            ['key' => 'lainnya', 'label' => 'Lainnya', 'slugs' => ['wedding-organizer', 'perhiasan', 'transportasi', 'akomodasi', 'hantaran', 'rental', 'legal', 'honeymoon']],
        ];
    }
}
