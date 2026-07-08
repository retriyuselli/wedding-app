<?php

namespace App\Filament\Resources\WeddingInfos\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class WeddingInfoForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Setiap pengantin memiliki satu profil info pernikahan yang ditampilkan di dashboard aplikasi.')
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

                Section::make('Pasangan')
                    ->description('Nama mempelai yang tampil di undangan dan dashboard.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('groom_name')
                            ->label('Nama Mempelai Pria')
                            ->maxLength(255)
                            ->placeholder('Nama lengkap atau panggilan'),
                        TextInput::make('bride_name')
                            ->label('Nama Mempelai Wanita')
                            ->maxLength(255)
                            ->placeholder('Nama lengkap atau panggilan'),
                    ]),

                Section::make('Konsep & Musik')
                    ->description('Budaya adat, tema konsep, dan daftar lagu favorit pernikahan.')
                    ->schema([
                        TextInput::make('budaya')
                            ->label('Budaya / Tema Konsep')
                            ->maxLength(100)
                            ->placeholder('Jawa, Sunda, Garden Romantic, Rustic, ...')
                            ->helperText('Budaya adat atau tema dekorasi yang dipakai pasangan.')
                            ->columnSpanFull(),
                        TagsInput::make('songlist')
                            ->label('Daftar Lagu')
                            ->placeholder('Ketik judul lagu lalu Enter')
                            ->helperText('Contoh: Perfect - Ed Sheeran, Sempurna - Andra and The Backbone.')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
