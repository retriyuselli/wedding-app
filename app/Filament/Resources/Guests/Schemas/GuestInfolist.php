<?php

namespace App\Filament\Resources\Guests\Schemas;

use App\Models\Guest;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class GuestInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('name'),
                TextEntry::make('phone')
                    ->placeholder('-'),
                TextEntry::make('email')
                    ->label('Email address')
                    ->placeholder('-'),
                TextEntry::make('table_number')
                    ->label('Nomor Meja')
                    ->placeholder('-'),
                TextEntry::make('rsvp_status')
                    ->label('RSVP')
                    ->formatStateUsing(fn (string $state): string => Guest::$rsvpOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'hadir' => 'success',
                        'tidak_hadir' => 'danger',
                        default => 'warning',
                    }),
                TextEntry::make('rsvp_updated_by_name')
                    ->label('Diperbarui Oleh')
                    ->placeholder('-'),
                TextEntry::make('rsvp_updated_at')
                    ->label('RSVP Diperbarui Pada')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('catatan')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
