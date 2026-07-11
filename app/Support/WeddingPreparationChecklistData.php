<?php

namespace App\Support;

class WeddingPreparationChecklistData
{
    /**
     * @return array<string, array<int, array{title: string, icon: string, tasks: array<int, string>}>>
     */
    public static function all(): array
    {
        /** @var array<string, array<int, array{title: string, icon: string, tasks: array<int, string>}>> $data */
        $data = require database_path('data/wedding_preparation_checklists.php');

        return $data;
    }

    /**
     * @return array<int, array{title: string, icon: string, tasks: array<int, string>}>
     */
    public static function forJenis(string $jenisAcara): array
    {
        return self::all()[$jenisAcara] ?? [];
    }

    /**
     * @return list<string>
     */
    public static function jenisAcaraOptions(): array
    {
        return array_keys(self::all());
    }
}
