<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Schemas;

use App\Models\WeddingPaymentSchedule;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class WeddingPaymentScheduleForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer & Konteks')
                    ->description('Hubungkan expense dengan pengantin, acara, dan metode pembayaran.')
                    ->columns(2)
                    ->schema([
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->live()
                            ->columnSpanFull(),
                        Select::make('wedding_event_id')
                            ->label('Acara Pernikahan')
                            ->relationship(
                                name: 'weddingEvent',
                                titleAttribute: 'jenis_acara',
                                modifyQueryUsing: fn ($query, Get $get) => filled($get('user_id'))
                                    ? $query->where('user_id', $get('user_id'))
                                    : $query,
                            )
                            ->searchable()
                            ->preload()
                            ->placeholder('Pilih acara (opsional)'),
                        Select::make('customer_payment_method_id')
                            ->label('Metode Pembayaran')
                            ->relationship(
                                name: 'paymentMethod',
                                titleAttribute: 'name',
                                modifyQueryUsing: fn ($query, Get $get) => filled($get('user_id'))
                                    ? $query->where('user_id', $get('user_id'))
                                    : $query,
                            )
                            ->searchable()
                            ->preload()
                            ->placeholder('Pilih metode (opsional)'),
                    ]),

                Section::make('Detail Expense')
                    ->description('Informasi pengeluaran yang tercatat di aplikasi mobile.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('title')
                            ->label('Judul')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('DP Venue, Pelunasan Catering, ...')
                            ->columnSpanFull(),
                        TextInput::make('vendor_name')
                            ->label('Vendor')
                            ->maxLength(255)
                            ->placeholder('Nama vendor atau penyedia jasa'),
                        Select::make('category')
                            ->label('Kategori')
                            ->options(WeddingPaymentSchedule::$categoryOptions)
                            ->searchable()
                            ->native(false)
                            ->placeholder('Pilih kategori'),
                    ]),

                Section::make('Nominal & Jadwal')
                    ->columns(2)
                    ->schema([
                        TextInput::make('amount')
                            ->label('Nominal')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->prefix('Rp')
                            ->step(1)
                            ->default(0),
                        DatePicker::make('due_date')
                            ->label('Jatuh Tempo')
                            ->native(false)
                            ->displayFormat('d M Y'),
                    ]),

                Section::make('Status Pembayaran')
                    ->description('Perbarui status setelah customer melakukan pembayaran.')
                    ->columns(2)
                    ->schema([
                        Select::make('status')
                            ->label('Status')
                            ->options(WeddingPaymentSchedule::$statusOptions)
                            ->required()
                            ->default('pending')
                            ->live()
                            ->native(false),
                        DateTimePicker::make('paid_at')
                            ->label('Dibayar Pada')
                            ->visible(fn (Get $get): bool => $get('status') === 'paid')
                            ->native(false),
                    ]),

                Section::make('Bukti & Catatan')
                    ->schema([
                        FileUpload::make('proof_url')
                            ->label('Bukti Pembayaran')
                            ->disk('public')
                            ->directory('payment-schedules/proofs')
                            ->visibility('public')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
                            ->maxSize(2048)
                            ->downloadable()
                            ->openable()
                            ->helperText('Unggah foto atau PDF bukti pembayaran (maks. 2 MB).')
                            ->columnSpanFull(),
                        Textarea::make('notes')
                            ->label('Catatan')
                            ->rows(3)
                            ->placeholder('Catatan tambahan untuk admin atau customer.')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
