<?php

namespace App\Support;

class FacilityItemParser
{
    /**
     * @param  list<string>|null  $items
     */
    public static function toText(?array $items): string
    {
        if ($items === null || $items === []) {
            return '';
        }

        return collect($items)
            ->map(static function (mixed $item): string {
                if (! is_string($item)) {
                    return '';
                }

                return trim($item);
            })
            ->filter(static fn (string $item): bool => filled($item))
            ->implode("\n");
    }

    /**
     * @return list<string>
     */
    public static function fromText(?string $text): array
    {
        if (blank($text)) {
            return [];
        }

        $lines = preg_split('/\R/u', $text) ?: [];

        return collect($lines)
            ->map(static fn (string $line): string => self::cleanLine($line))
            ->filter(static fn (string $line): bool => filled($line))
            ->values()
            ->all();
    }

    public static function cleanLine(string $line): string
    {
        $line = trim($line);

        if ($line === '') {
            return '';
        }

        $line = preg_replace('/^[\-\–\—\*•·▪▸►✓✔→]\s*/u', '', $line) ?? $line;
        $line = preg_replace('/^\(?\d{1,3}\s*[\.\)\:\-]\s*/', '', $line) ?? $line;

        return trim($line);
    }
}
