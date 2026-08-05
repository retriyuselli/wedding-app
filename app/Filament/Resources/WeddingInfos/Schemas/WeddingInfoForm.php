<?php

namespace App\Filament\Resources\WeddingInfos\Schemas;

use App\Models\WeddingInfo;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
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
                            ->live()
                            ->columnSpanFull(),
                    ]),

                Section::make('Mempelai Wanita')
                    ->columns(2)
                    ->schema([
                        TextInput::make('bride_name')
                            ->label('Nama Panggilan')
                            ->maxLength(255)
                            ->placeholder('Contoh: Anya'),
                        TextInput::make('bride_full_name')
                            ->label('Nama Lengkap')
                            ->maxLength(255)
                            ->placeholder('Nama lengkap mempelai wanita'),
                        TextInput::make('bride_phone')
                            ->label('No. Telepon')
                            ->tel()
                            ->maxLength(50)
                            ->placeholder('08xxxxxxxxxx'),
                        TextInput::make('bride_father_name')
                            ->label('Nama Ortu Laki-laki')
                            ->maxLength(255),
                        TextInput::make('bride_mother_name')
                            ->label('Nama Ortu Perempuan')
                            ->maxLength(255),
                    ]),

                Section::make('Mempelai Pria')
                    ->columns(2)
                    ->schema([
                        TextInput::make('groom_name')
                            ->label('Nama Panggilan')
                            ->maxLength(255)
                            ->placeholder('Contoh: Afif'),
                        TextInput::make('groom_full_name')
                            ->label('Nama Lengkap')
                            ->maxLength(255)
                            ->placeholder('Nama lengkap mempelai pria'),
                        TextInput::make('groom_phone')
                            ->label('No. Telepon')
                            ->tel()
                            ->maxLength(50)
                            ->placeholder('08xxxxxxxxxx'),
                        TextInput::make('groom_father_name')
                            ->label('Nama Ortu Laki-laki')
                            ->maxLength(255),
                        TextInput::make('groom_mother_name')
                            ->label('Nama Ortu Perempuan')
                            ->maxLength(255),
                    ]),

                Section::make('Foto Berdua')
                    ->description('Foto pasangan yang ditampilkan di Beranda / Home aplikasi mobile.')
                    ->schema([
                        FileUpload::make('couple_photo')
                            ->label('Foto Berdua')
                            ->image()
                            ->disk('public')
                            ->directory(function (Get $get, ?WeddingInfo $record): string {
                                $userId = $get('user_id') ?: $record?->user_id;

                                return 'couple-photos/'.($userId ?: 'pending');
                            })
                            ->visibility('public')
                            ->imageEditor()
                            ->maxSize(2048)
                            ->helperText('Format JPG/PNG. Maksimal 2 MB. Digunakan di kartu pasangan pada Beranda.')
                            ->columnSpanFull(),
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
