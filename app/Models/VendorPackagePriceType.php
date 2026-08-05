<?php

namespace App\Models;

enum VendorPackagePriceType: string
{
    case Fixed = 'fixed';
    case StartingFrom = 'starting_from';
    case Custom = 'custom';

    public function label(): string
    {
        return match ($this) {
            self::Fixed => 'Harga Tetap',
            self::StartingFrom => 'Mulai Dari',
            self::Custom => 'Konsultasi',
        };
    }
}
