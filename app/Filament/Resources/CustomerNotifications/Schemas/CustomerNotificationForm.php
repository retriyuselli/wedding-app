<?php

namespace App\Filament\Resources\CustomerNotifications\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class CustomerNotificationForm
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
                TextInput::make('group'),
                TextInput::make('title')
                    ->required(),
                Textarea::make('message')
                    ->columnSpanFull(),
                TextInput::make('icon'),
                TextInput::make('destination'),
                TextInput::make('tint'),
                Toggle::make('is_unread')
                    ->label('Belum Dibaca')
                    ->default(true),
            ]);
    }
}
