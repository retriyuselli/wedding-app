<?php

namespace App\Enums;

enum SupportMessageTopic: string
{
    case Account = 'account';
    case Budget = 'budget';
    case Checklist = 'checklist';
    case Guests = 'guests';
    case Other = 'other';

    public function label(): string
    {
        return match ($this) {
            self::Account => 'Akun & Login',
            self::Budget => 'Budget & Pembayaran',
            self::Checklist => 'Checklist & Persiapan',
            self::Guests => 'Tamu & Undangan',
            self::Other => 'Lainnya',
        };
    }
}
