<?php

namespace App\Filament\Resources\WeddingInfos\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class WeddingInfoInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('groom_name')
                    ->placeholder('-'),
                TextEntry::make('bride_name')
                    ->placeholder('-'),
                TextEntry::make('budaya')
                    ->placeholder('-'),
                TextEntry::make('songlist')
                    ->badge()
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
