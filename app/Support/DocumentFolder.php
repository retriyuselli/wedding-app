<?php

namespace App\Support;

class DocumentFolder
{
    public const All = 'all';

    public const Vendor = 'vendor';

    public const Finance = 'finance';

    public const Design = 'design';

    public const Legal = 'legal';

    /**
     * @return array<string, array{
     *     label: string,
     *     icon_bg: string,
     *     icon_text: string,
     *     badge_bg: string,
     *     badge_text: string,
     *     keywords: array<int, string>
     * }>
     */
    public static function definitions(): array
    {
        return [
            self::All => [
                'label' => 'Semua Dokumen',
                'icon_bg' => 'bg-sage-100',
                'icon_text' => 'text-sage-700',
                'badge_bg' => 'bg-sage-50',
                'badge_text' => 'text-sage-700',
                'keywords' => [],
            ],
            self::Vendor => [
                'label' => 'Kontrak Vendor',
                'icon_bg' => 'bg-orange-50',
                'icon_text' => 'text-orange-600',
                'badge_bg' => 'bg-orange-50',
                'badge_text' => 'text-orange-700',
                'keywords' => ['vendor', 'invoice', 'catering', 'mua', 'wedding organizer', 'wo', 'kontrak', 'dekorasi', 'katering', 'fotografi'],
            ],
            self::Finance => [
                'label' => 'Keuangan',
                'icon_bg' => 'bg-teal-50',
                'icon_text' => 'text-teal-600',
                'badge_bg' => 'bg-teal-50',
                'badge_text' => 'text-teal-700',
                'keywords' => ['anggaran', 'budget', 'keuangan', 'biaya', 'pembayaran', 'kwitansi', 'rincian', 'invoice', 'termin'],
            ],
            self::Design => [
                'label' => 'Undangan & Desain',
                'icon_bg' => 'bg-amber-50',
                'icon_text' => 'text-amber-600',
                'badge_bg' => 'bg-amber-50',
                'badge_text' => 'text-amber-700',
                'keywords' => ['undangan', 'desain', 'souvenir', 'ballroom', 'dokumentasi', 'resepsi', 'mockup', 'layout'],
            ],
            self::Legal => [
                'label' => 'Legal & Surat',
                'icon_bg' => 'bg-violet-50',
                'icon_text' => 'text-violet-600',
                'badge_bg' => 'bg-violet-50',
                'badge_text' => 'text-violet-700',
                'keywords' => ['legal', 'surat', 'berkas', 'fotokopi', 'ktp', 'akta', 'kua', 'n1', 'n4', 'buku nikah', 'ijazah', 'perjanjian'],
            ],
        ];
    }

    /**
     * @return array<int, string>
     */
    public static function selectableFolders(): array
    {
        return [
            self::All,
            self::Vendor,
            self::Finance,
            self::Design,
            self::Legal,
        ];
    }

    public static function label(string $folder): string
    {
        return self::definitions()[$folder]['label'] ?? 'Lainnya';
    }

    /**
     * @return array{badge_bg: string, badge_text: string}
     */
    public static function badgeClasses(string $folder): array
    {
        $definition = self::definitions()[$folder] ?? self::definitions()[self::Vendor];

        return [
            'badge_bg' => $definition['badge_bg'],
            'badge_text' => $definition['badge_text'],
        ];
    }

    public static function match(string $taskTitle, string $fileName): string
    {
        $haystack = strtolower("{$taskTitle} {$fileName}");

        foreach ([self::Legal, self::Finance, self::Design, self::Vendor] as $folder) {
            $keywords = self::definitions()[$folder]['keywords'];

            foreach ($keywords as $keyword) {
                if (str_contains($haystack, $keyword)) {
                    return $folder;
                }
            }
        }

        $extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

        if (in_array($extension, ['xls', 'xlsx', 'csv'], true)) {
            return self::Finance;
        }

        if (in_array($extension, ['jpg', 'jpeg', 'png', 'webp'], true)) {
            return self::Design;
        }

        return self::Vendor;
    }
}
