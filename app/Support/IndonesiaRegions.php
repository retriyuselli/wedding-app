<?php

namespace App\Support;

use Illuminate\Support\Facades\Cache;

class IndonesiaRegions
{
    /**
     * @return array<string, list<string>>
     */
    public static function all(): array
    {
        return Cache::rememberForever('indonesia.regions', function (): array {
            $path = config('indonesia.regions_file');

            if (! is_string($path) || ! is_readable($path)) {
                return [];
            }

            $json = file_get_contents($path);
            $data = json_decode($json ?: '[]', true);

            return is_array($data) ? $data : [];
        });
    }

    /**
     * @return list<string>
     */
    public static function provinces(): array
    {
        return array_keys(static::all());
    }

    /**
     * @return list<string>
     */
    public static function cities(?string $province): array
    {
        if ($province === null || $province === '') {
            return [];
        }

        $regions = static::all();

        if (isset($regions[$province])) {
            return $regions[$province];
        }

        foreach ($regions as $name => $cities) {
            if (strcasecmp($name, $province) === 0) {
                return $cities;
            }
        }

        return [];
    }

    public static function isValidProvince(string $province): bool
    {
        return static::cities($province) !== [];
    }

    public static function isValidCity(string $province, string $city): bool
    {
        return in_array($city, static::cities($province), true);
    }

    /**
     * @return array<string, string>
     */
    public static function provinceOptions(): array
    {
        $provinces = static::provinces();

        return array_combine($provinces, $provinces) ?: [];
    }

    /**
     * @return array<string, string>
     */
    public static function cityOptions(?string $province): array
    {
        $cities = static::cities($province);

        return array_combine($cities, $cities) ?: [];
    }
}
