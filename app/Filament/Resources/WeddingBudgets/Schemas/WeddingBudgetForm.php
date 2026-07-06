<?php

namespace App\Filament\Resources\WeddingBudgets\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class WeddingBudgetForm
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
                TextInput::make('total_budget')
                    ->label('Total Budget')
                    ->required()
                    ->numeric()
                    ->prefix('Rp')
                    ->default(0.0),
                TextInput::make('currency')
                    ->required()
                    ->default('IDR'),
                Textarea::make('notes')
                    ->columnSpanFull(),
            ]);
    }
}
