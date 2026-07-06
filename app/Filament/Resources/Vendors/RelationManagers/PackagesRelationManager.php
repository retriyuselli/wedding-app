<?php

namespace App\Filament\Resources\Vendors\RelationManagers;

use App\Models\VendorPackagePriceType;
use App\Support\FacilityItemParser;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class PackagesRelationManager extends RelationManager
{
    protected static string $relationship = 'packages';

    protected static ?string $title = 'Paket Pernikahan';

    protected static ?string $modelLabel = 'Paket';

    protected static ?string $pluralModelLabel = 'Paket';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->columns(2)
            ->components([
                TextInput::make('name')
                    ->label('Nama Paket')
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
                    ->alphaDash()
                    ->helperText('Otomatis dari nama. Bisa disesuaikan manual jika perlu.')
                    ->columnSpanFull(),
                Textarea::make('description')
                    ->label('Ringkasan Paket')
                    ->helperText('Kalimat singkat di atas daftar fasilitas. Untuk detail bullet, gunakan form Fasilitas di bawah.')
                    ->rows(2)
                    ->columnSpanFull(),
                Select::make('price_type')
                    ->label('Tipe Harga')
                    ->options(VendorPackagePriceType::class)
                    ->default(VendorPackagePriceType::Fixed)
                    ->required()
                    ->live(),
                TextInput::make('price')
                    ->label('Harga (Rp)')
                    ->numeric()
                    ->prefix('Rp')
                    ->visible(fn (Get $get): bool => $get('price_type') !== VendorPackagePriceType::Custom->value),
                TextInput::make('capacity_min')
                    ->label('Kapasitas Min')
                    ->numeric()
                    ->minValue(1),
                TextInput::make('capacity_max')
                    ->label('Kapasitas Max')
                    ->numeric()
                    ->minValue(1),
                TextInput::make('duration_hours')
                    ->label('Durasi (jam)')
                    ->numeric()
                    ->minValue(1),
                FileUpload::make('cover_image')
                    ->label('Gambar Paket')
                    ->image()
                    ->disk('public')
                    ->directory('vendors/packages')
                    ->visibility('public')
                    ->columnSpanFull(),
                Repeater::make('facility_sections')
                    ->label('Fasilitas')
                    ->schema([
                        TextInput::make('title')
                            ->label('Judul Grup')
                            ->placeholder('Contoh: Dekorasi by Hj. Nila, Naraya, PPM 2')
                            ->required()
                            ->columnSpanFull(),
                        Textarea::make('items')
                            ->label('Item Fasilitas')
                            ->placeholder("Tempel daftar paket di sini — satu baris = satu item.\nContoh:\n1. Dekorasi lamaran dan meja kursi\n2. Menu Ayam, Ikan, daging\n3. Photographer dan videographer")
                            ->helperText('Copy-paste dari PDF, Word, atau WhatsApp. Nomor urut dan bullet otomatis dibersihkan; urutan baris = nomor 1, 2, 3 di aplikasi.')
                            ->rows(8)
                            ->required()
                            ->columnSpanFull()
                            ->afterStateHydrated(function (Textarea $component, mixed $state): void {
                                if (is_array($state)) {
                                    $component->state(FacilityItemParser::toText($state));
                                }
                            })
                            ->dehydrateStateUsing(fn (?string $state): array => FacilityItemParser::fromText($state)),
                    ])
                    ->columnSpanFull()
                    ->collapsible()
                    ->defaultItems(0)
                    ->addActionLabel('Tambah grup fasilitas')
                    ->itemLabel(fn (array $state): ?string => $state['title'] ?? null),
                Textarea::make('exclusions')
                    ->label('Tidak Termasuk')
                    ->placeholder("Tempel daftar item yang tidak termasuk — satu baris = satu item.")
                    ->helperText('Copy-paste didukung. Nomor dan bullet otomatis dibersihkan.')
                    ->rows(4)
                    ->columnSpanFull()
                    ->afterStateHydrated(function (Textarea $component, mixed $state): void {
                        if (is_array($state)) {
                            $component->state(FacilityItemParser::toText($state));
                        }
                    })
                    ->dehydrateStateUsing(fn (?string $state): array => FacilityItemParser::fromText($state)),
                Toggle::make('is_featured')
                    ->label('Unggulan')
                    ->default(false),
                Toggle::make('is_active')
                    ->label('Aktif')
                    ->default(true),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->defaultSort('sort_order')
            ->recordTitleAttribute('name')
            ->columns([
                TextColumn::make('name')
                    ->label('Nama Paket')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('price_type')
                    ->label('Tipe Harga')
                    ->badge(),
                TextColumn::make('price')
                    ->label('Harga')
                    ->money('IDR')
                    ->sortable(),
                TextColumn::make('capacity_max')
                    ->label('Kapasitas')
                    ->formatStateUsing(fn (?int $state, $record): string => match (true) {
                        $record->capacity_min && $state => "{$record->capacity_min}–{$state} pax",
                        (bool) $state => "≤ {$state} pax",
                        default => '—',
                    }),
                IconColumn::make('is_featured')
                    ->label('Unggulan')
                    ->boolean(),
                IconColumn::make('is_active')
                    ->label('Aktif')
                    ->boolean(),
                TextColumn::make('sort_order')
                    ->label('Urutan')
                    ->sortable(),
            ])
            ->headerActions([
                CreateAction::make(),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
