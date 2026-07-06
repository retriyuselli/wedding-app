<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class CustomerPaymentMethodForm
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
                TextInput::make('name')
                    ->required(),
                TextInput::make('logo_icon'),
                TextInput::make('account_number'),
                TextInput::make('account_name'),
                Toggle::make('is_primary')
                    ->default(false),
                TextInput::make('type'),
            ]);
    }
}
