<?php

namespace App\Filament\Resources\CustomerPreparationSections\Schemas;

use App\Models\CustomerPreparationSection;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CustomerPreparationSectionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Pilih pengantin yang memiliki bagian checklist ini.')
                    ->schema([
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->columnSpanFull(),
                    ]),

                Section::make('Informasi Bagian')
                    ->description('Judul dan ikon yang ditampilkan di tab checklist aplikasi mobile.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('title')
                            ->label('Judul Bagian')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Dokumen, Vendor, Busana, Venue, ...')
                            ->columnSpanFull(),
                        Select::make('icon')
                            ->label('Ikon SF Symbol')
                            ->options(CustomerPreparationSection::$iconOptions)
                            ->searchable()
                            ->preload()
                            ->native(false)
                            ->placeholder('Pilih ikon')
                            ->helperText('Nama ikon SF Symbol yang dipakai di iOS, mis. person.2 atau camera.'),
                    ]),
            ]);
    }
}
