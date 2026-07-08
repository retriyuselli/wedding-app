<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Schemas;

use App\Models\CustomerPaymentMethod;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class CustomerPaymentMethodForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Pilih akun pengantin yang memiliki metode pembayaran ini.')
                    ->schema([
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->columnSpanFull(),
                    ]),

                Section::make('Metode Pembayaran')
                    ->description('Nama dan jenis metode yang ditampilkan di aplikasi mobile.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('name')
                            ->label('Nama Metode')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('BCA, Mandiri, GoPay, ...')
                            ->columnSpanFull(),
                        Select::make('type')
                            ->label('Jenis')
                            ->options(CustomerPaymentMethod::$typeOptions)
                            ->default('bank')
                            ->required()
                            ->native(false)
                            ->live(),
                        TextInput::make('logo_icon')
                            ->label('Ikon (Opsional)')
                            ->maxLength(255)
                            ->placeholder('building.columns')
                            ->helperText('Nama SF Symbol atau kode ikon internal. Kosongkan jika tidak dipakai.'),
                    ]),

                Section::make('Detail Rekening')
                    ->description('Informasi rekening atau nomor yang ditampilkan saat customer membayar.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('account_number')
                            ->label(fn (Get $get): string => match ($get('type')) {
                                'e-wallet' => 'Nomor HP / ID E-Wallet',
                                'cash' => 'Keterangan Tunai',
                                default => 'Nomor Rekening',
                            })
                            ->maxLength(255)
                            ->placeholder(fn (Get $get): string => match ($get('type')) {
                                'e-wallet' => '08xxxxxxxxxx',
                                'cash' => 'Bayar tunai ke keluarga',
                                default => '1234567890',
                            }),
                        TextInput::make('account_name')
                            ->label('Atas Nama')
                            ->maxLength(255)
                            ->placeholder('Nama pemilik rekening'),
                    ]),

                Section::make('Pengaturan')
                    ->schema([
                        Toggle::make('is_primary')
                            ->label('Jadikan metode utama')
                            ->helperText('Metode utama akan diprioritaskan di aplikasi. Disarankan hanya satu per customer.')
                            ->default(false)
                            ->inline(false),
                    ]),
            ]);
    }
}
