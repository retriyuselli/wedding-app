<?php

namespace App\Filament\Resources\WeddingBudgets\Schemas;

use App\Models\WeddingBudget;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class WeddingBudgetForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Setiap pengantin memiliki satu anggaran pernikahan yang dipakai di aplikasi mobile.')
                    ->schema([
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->native(false)
                            ->columnSpanFull(),
                    ]),

                Section::make('Anggaran')
                    ->description('Total target anggaran pernikahan. Expense dan alokasi kategori dikelola di menu terkait.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('total_budget')
                            ->label('Total Anggaran')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->prefix('Rp')
                            ->step(1)
                            ->default(0)
                            ->placeholder('0')
                            ->helperText('Nominal keseluruhan yang direncanakan untuk pernikahan.'),
                        Select::make('currency')
                            ->label('Mata Uang')
                            ->options(WeddingBudget::$currencyOptions)
                            ->required()
                            ->default(WeddingBudget::defaultCurrency())
                            ->native(false)
                            ->helperText('Saat ini aplikasi mendukung Rupiah (IDR).'),
                    ]),

                Section::make('Catatan')
                    ->schema([
                        Textarea::make('notes')
                            ->label('Catatan Anggaran')
                            ->rows(3)
                            ->placeholder('Asumsi anggaran, sumber dana, atau catatan internal.')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
