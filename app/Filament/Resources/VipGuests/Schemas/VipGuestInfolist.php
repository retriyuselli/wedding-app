<?php

namespace App\Filament\Resources\VipGuests\Schemas;

use App\Models\VipGuest;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class VipGuestInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('no')
                    ->label('No')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('name'),
                TextEntry::make('jabatan')
                    ->placeholder('-'),
                TextEntry::make('instansi')
                    ->placeholder('-'),
                TextEntry::make('phone')
                    ->placeholder('-'),
                TextEntry::make('kategori')
                    ->formatStateUsing(fn (string $state): string => VipGuest::$kategoriOptions[$state] ?? $state)
                    ->badge(),
                TextEntry::make('rsvp_status')
                    ->label('RSVP')
                    ->formatStateUsing(fn (string $state): string => VipGuest::$rsvpOptions[$state] ?? $state)
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
