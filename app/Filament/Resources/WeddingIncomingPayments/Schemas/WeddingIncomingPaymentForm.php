<?php

namespace App\Filament\Resources\WeddingIncomingPayments\Schemas;

use App\Models\WeddingIncomingPayment;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class WeddingIncomingPaymentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Pilih akun pengantin yang menerima uang masuk ini.')
                    ->schema([
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->columnSpanFull(),
                    ]),

                Section::make('Detail Transfer')
                    ->description('Data transfer dari keluarga, tamu, atau pihak lain.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('sender_name')
                            ->label('Nama Pengirim')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Nama lengkap pengirim')
                            ->columnSpanFull(),
                        TextInput::make('amount')
                            ->label('Nominal')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->prefix('Rp')
                            ->step(1)
                            ->default(0),
                        DatePicker::make('transfer_date')
                            ->label('Tanggal Transfer')
                            ->required()
                            ->default(now())
                            ->maxDate(now())
                            ->native(false)
                            ->displayFormat('d M Y'),
                        TextInput::make('bank_name')
                            ->label('Bank Pengirim')
                            ->maxLength(255)
                            ->placeholder('BCA, Mandiri, BNI, ...'),
                        TextInput::make('reference_number')
                            ->label('Nomor Referensi')
                            ->maxLength(255)
                            ->placeholder('No. referensi / berita transfer'),
                    ]),

                Section::make('Bukti & Keterangan')
                    ->columns(2)
                    ->schema([
                        FileUpload::make('proof_url')
                            ->label('Bukti Transfer')
                            ->disk('public')
                            ->directory('incoming-payments/proofs')
                            ->visibility('public')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
                            ->maxSize(2048)
                            ->downloadable()
                            ->openable()
                            ->helperText('Unggah foto atau PDF bukti transfer (maks. 2 MB).')
                            ->columnSpanFull(),
                        Textarea::make('description')
                            ->label('Keterangan')
                            ->rows(2)
                            ->placeholder('Mis. hadiah dari keluarga, amplop acara, dll.')
                            ->columnSpanFull(),
                        Textarea::make('notes')
                            ->label('Catatan Internal')
                            ->rows(3)
                            ->placeholder('Catatan untuk admin, tidak ditampilkan ke customer.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Verifikasi')
                    ->description('Konfirmasi atau tolak setelah bukti transfer dicek.')
                    ->columns(2)
                    ->schema([
                        Select::make('status')
                            ->label('Status')
                            ->options(WeddingIncomingPayment::$statusOptions)
                            ->required()
                            ->default('menunggu')
                            ->live()
                            ->native(false),
                        DateTimePicker::make('confirmed_at')
                            ->label('Dikonfirmasi Pada')
                            ->visible(fn (Get $get): bool => $get('status') === 'confirmed')
                            ->native(false),
                        TextInput::make('confirmed_by')
                            ->label('Dikonfirmasi Oleh')
                            ->maxLength(255)
                            ->placeholder('Nama admin')
                            ->visible(fn (Get $get): bool => $get('status') === 'confirmed')
                            ->columnSpanFull(),
                        Textarea::make('rejection_reason')
                            ->label('Alasan Penolakan')
                            ->rows(3)
                            ->required(fn (Get $get): bool => $get('status') === 'rejected')
                            ->visible(fn (Get $get): bool => $get('status') === 'rejected')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
