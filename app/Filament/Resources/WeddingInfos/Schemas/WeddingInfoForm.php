<?php

namespace App\Filament\Resources\WeddingInfos\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class WeddingInfoForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                TextInput::make('groom_name'),
                TextInput::make('bride_name'),
                TextInput::make('budaya'),
                TagsInput::make('songlist')
                    ->columnSpanFull(),
            ]);
    }
}
