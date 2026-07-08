<?php

namespace App\Support;

class DummyImage
{
    /**
     * @var array<string, string|list<string>>
     */
    private const ASSETS = [
        'couple' => 'images/dashboard/dummy-couple.svg',
        'avatar' => 'images/dashboard/dummy-avatar.svg',
        'vendor' => [
            'images/dashboard/dummy-vendor-1.svg',
            'images/dashboard/dummy-vendor-2.svg',
            'images/dashboard/dummy-vendor-3.svg',
            'images/dashboard/dummy-vendor-4.svg',
        ],
        'inspiration' => [
            'images/dashboard/dummy-inspiration-1.svg',
            'images/dashboard/dummy-inspiration-2.svg',
            'images/dashboard/dummy-inspiration-3.svg',
        ],
        'message' => [
            'images/dashboard/dummy-message-1.svg',
            'images/dashboard/dummy-message-2.svg',
            'images/dashboard/dummy-message-3.svg',
        ],
    ];

    public static function url(string $type, int $index = 0): string
    {
        $asset = self::ASSETS[$type] ?? self::ASSETS['avatar'];

        if (is_array($asset)) {
            $asset = $asset[$index % count($asset)];
        }

        return asset($asset);
    }
}
