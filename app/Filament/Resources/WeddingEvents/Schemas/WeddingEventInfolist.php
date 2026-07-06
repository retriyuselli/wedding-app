<?php

namespace App\Filament\Resources\WeddingEvents\Schemas;

use App\Models\WeddingEvent;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class WeddingEventInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('jenis_acara')
                    ->label('Jenis Acara')
                    ->formatStateUsing(fn (string $state): string => WeddingEvent::$jenisOptions[$state] ?? $state)
                    ->badge(),
                TextEntry::make('tgl_acara')
                    ->label('Tanggal Acara')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('lokasi_acara')
                    ->label('Lokasi Acara')
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
