<?php

namespace App\Filament\Resources\WeddingQuotes\Schemas;

use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class WeddingQuoteForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Quote Carousel')
                    ->schema([
                        Textarea::make('quote')
                            ->label('Kutipan')
                            ->required()
                            ->rows(4)
                            ->maxLength(500)
                            ->columnSpanFull(),
                        Toggle::make('is_active')
                            ->label('Aktif')
                            ->default(true)
                            ->required(),
                    ]),
            ]);
    }
}
