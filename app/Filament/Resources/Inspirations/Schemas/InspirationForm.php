<?php

namespace App\Filament\Resources\Inspirations\Schemas;

use App\Models\Inspiration;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class InspirationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Konten')
                    ->columns(2)
                    ->schema([
                        TextInput::make('title')
                            ->label('Judul')
                            ->required()
                            ->maxLength(150)
                            ->columnSpanFull(),
                        Textarea::make('description')
                            ->label('Deskripsi')
                            ->rows(4)
                            ->maxLength(1000)
                            ->columnSpanFull(),
                        Select::make('category')
                            ->label('Kategori')
                            ->options(Inspiration::$categoryOptions)
                            ->required()
                            ->searchable(),
                        TextInput::make('thumbnail_symbol')
                            ->label('Ikon Thumbnail')
                            ->helperText('Nama SF Symbol untuk fallback jika gambar kosong, contoh: leaf.fill')
                            ->maxLength(80)
                            ->placeholder('leaf.fill'),
                    ]),

                Section::make('Media')
                    ->schema([
                        FileUpload::make('image_url')
                            ->label('Gambar')
                            ->image()
                            ->disk('public')
                            ->directory('inspirations')
                            ->visibility('public')
                            ->imageEditor()
                            ->maxSize(4096)
                            ->helperText('Unggah gambar inspirasi. Disarankan rasio horizontal.'),
                    ]),

                Section::make('Tampilan & Statistik')
                    ->columns(2)
                    ->schema([
                        Toggle::make('is_active')
                            ->label('Aktif')
                            ->default(true)
                            ->required(),
                        TextInput::make('sort_order')
                            ->label('Urutan')
                            ->numeric()
                            ->default(0)
                            ->required()
                            ->minValue(0),
                        TextInput::make('likes_count')
                            ->label('Jumlah Suka')
                            ->numeric()
                            ->default(0)
                            ->required()
                            ->minValue(0),
                        TextInput::make('views_count')
                            ->label('Jumlah Dilihat')
                            ->numeric()
                            ->default(0)
                            ->required()
                            ->minValue(0),
                    ]),
            ]);
    }
}
