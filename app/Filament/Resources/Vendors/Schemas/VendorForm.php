<?php

namespace App\Filament\Resources\Vendors\Schemas;

use App\Support\IndonesiaRegions;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class VendorForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Informasi Utama')
                    ->columns(2)
                    ->schema([
                        Select::make('category_id')
                            ->label('Kategori')
                            ->relationship(
                                name: 'category',
                                titleAttribute: 'name',
                                modifyQueryUsing: fn ($query) => $query->where('is_active', true)->orderBy('sort_order'),
                            )
                            ->searchable()
                            ->preload()
                            ->required(),
                        TextInput::make('name')
                            ->label('Nama Vendor')
                            ->required()
                            ->maxLength(150)
                            ->live(onBlur: true)
                            ->afterStateUpdated(function (Set $set, Get $get, ?string $state, ?string $old): void {
                                $currentSlug = $get('slug');
                                $previousAutoSlug = Str::slug($old ?? '');

                                if (blank($currentSlug) || $currentSlug === $previousAutoSlug) {
                                    $set('slug', Str::slug($state ?? ''));
                                }
                            })
                            ->columnSpanFull(),
                        TextInput::make('slug')
                            ->label('Slug')
                            ->required()
                            ->maxLength(180)
                            ->unique(ignoreRecord: true)
                            ->alphaDash()
                            ->helperText('Otomatis dari nama. Bisa disesuaikan manual jika perlu.')
                            ->columnSpanFull(),
                        Textarea::make('description')
                            ->label('Deskripsi')
                            ->rows(4)
                            ->columnSpanFull(),
                    ]),

                Section::make('Media')
                    ->columns(2)
                    ->schema([
                        FileUpload::make('logo')
                            ->label('Logo')
                            ->image()
                            ->disk('public')
                            ->directory('vendors/logos')
                            ->visibility('public')
                            ->maxSize(2048),
                        FileUpload::make('cover_image')
                            ->label('Gambar Sampul')
                            ->image()
                            ->disk('public')
                            ->directory('vendors/covers')
                            ->visibility('public')
                            ->maxSize(4096),
                    ]),

                Section::make('Lokasi')
                    ->columns(2)
                    ->schema([
                        Select::make('province')
                            ->label('Provinsi')
                            ->options(fn (): array => IndonesiaRegions::provinceOptions())
                            ->searchable()
                            ->live()
                            ->afterStateUpdated(fn (Set $set) => $set('city', null)),
                        Select::make('city')
                            ->label('Kota / Kabupaten')
                            ->options(fn (Get $get): array => IndonesiaRegions::cityOptions($get('province')))
                            ->searchable()
                            ->disabled(fn (Get $get): bool => blank($get('province')))
                            ->dehydrated(fn (Get $get): bool => filled($get('province'))),
                        Textarea::make('address')
                            ->label('Alamat Lengkap')
                            ->rows(3)
                            ->columnSpanFull(),
                    ]),

                Section::make('Kontak')
                    ->columns(2)
                    ->schema([
                        TextInput::make('phone')
                            ->label('Telepon / WhatsApp')
                            ->tel()
                            ->maxLength(30),
                        TextInput::make('email')
                            ->label('Email')
                            ->email()
                            ->maxLength(150),
                        TextInput::make('website')
                            ->label('Website')
                            ->url()
                            ->maxLength(255)
                            ->columnSpanFull(),
                        TextInput::make('instagram')
                            ->label('Instagram')
                            ->placeholder('@username')
                            ->maxLength(255)
                            ->columnSpanFull(),
                    ]),

                Section::make('Pengaturan')
                    ->columns(2)
                    ->schema([
                        Toggle::make('is_verified')
                            ->label('Terverifikasi')
                            ->default(false),
                        Toggle::make('is_featured')
                            ->label('Unggulan')
                            ->default(false),
                        Toggle::make('is_active')
                            ->label('Aktif')
                            ->default(true),
                    ]),
            ]);
    }
}
