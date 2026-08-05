<?php

namespace App\Filament\Resources\MessageThreads\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class MessageThreadForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Percakapan Support')
                    ->description('Informasi pengantin dan status tim support.')
                    ->columns(2)
                    ->schema([
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->disabled()
                            ->dehydrated(false)
                            ->columnSpanFull(),
                        TextInput::make('name')
                            ->label('Nama Thread')
                            ->disabled()
                            ->dehydrated(false),
                        Toggle::make('is_online')
                            ->label('Support Online')
                            ->helperText('Ditampilkan sebagai status online di aplikasi mobile.')
                            ->inline(false),
                    ]),
            ]);
    }
}
