<?php

namespace App\Filament\Resources\WeddingEvents\Schemas;

use App\Models\WeddingEvent;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class WeddingEventForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Pilih pengantin yang menyelenggarakan acara ini.')
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

                Section::make('Detail Acara')
                    ->description('Jenis, tanggal, dan lokasi acara yang ditampilkan di aplikasi mobile.')
                    ->columns(2)
                    ->schema([
                        Select::make('jenis_acara')
                            ->label('Jenis Acara')
                            ->options(WeddingEvent::$jenisOptions)
                            ->required()
                            ->native(false)
                            ->searchable()
                            ->columnSpanFull(),
                        DatePicker::make('tgl_acara')
                            ->label('Tanggal Acara')
                            ->native(false)
                            ->displayFormat('d M Y')
                            ->placeholder('Pilih tanggal'),
                        TimePicker::make('waktu_mulai')
                            ->label('Waktu Mulai')
                            ->seconds(false)
                            ->native(false),
                        TimePicker::make('jam_selesai')
                            ->label('Jam Selesai')
                            ->seconds(false)
                            ->native(false),
                        TextInput::make('lokasi_acara')
                            ->label('Lokasi Acara')
                            ->maxLength(255)
                            ->placeholder('Nama venue, alamat, atau kota')
                            ->columnSpanFull(),
                    ]),

                Section::make('Catatan & Integrasi')
                    ->description('Informasi tambahan dan referensi internal.')
                    ->schema([
                        Textarea::make('catatan')
                            ->label('Catatan Acara')
                            ->rows(3)
                            ->placeholder('Protokol, dress code, atau catatan khusus untuk acara ini.')
                            ->columnSpanFull(),
                        TextInput::make('vendor_booking_id')
                            ->label('ID Booking Vendor')
                            ->numeric()
                            ->minValue(1)
                            ->placeholder('Opsional')
                            ->helperText('Referensi booking vendor jika acara terhubung ke modul vendor.')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
