<?php

namespace App\Filament\Resources\VipGuests\Schemas;

use App\Models\VipGuest;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class VipGuestForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Pilih pengantin yang memiliki daftar tamu VIP ini.')
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

                Section::make('Identitas Tamu')
                    ->description('Data tamu VIP yang ditampilkan di daftar undangan khusus.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('no')
                            ->label('Nomor Urut')
                            ->numeric()
                            ->minValue(1)
                            ->placeholder('1, 2, 3, ...')
                            ->helperText('Opsional. Urutan tampil di daftar VIP.'),
                        TextInput::make('name')
                            ->label('Nama Lengkap')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Bapak / Ibu ...')
                            ->columnSpanFull(),
                        TextInput::make('jabatan')
                            ->label('Jabatan')
                            ->maxLength(255)
                            ->placeholder('Direktur, Kepala Dinas, ...'),
                        TextInput::make('instansi')
                            ->label('Instansi / Organisasi')
                            ->maxLength(255)
                            ->placeholder('Pemerintah Daerah, Perusahaan, ...'),
                        TextInput::make('phone')
                            ->label('Telepon / WhatsApp')
                            ->tel()
                            ->maxLength(255)
                            ->placeholder('08xxxxxxxxxx')
                            ->columnSpanFull(),
                    ]),

                Section::make('Kategori & RSVP')
                    ->columns(2)
                    ->schema([
                        Select::make('kategori')
                            ->label('Kategori Tamu')
                            ->options(VipGuest::$kategoriOptions)
                            ->required()
                            ->default('vip')
                            ->native(false)
                            ->searchable(),
                        Select::make('rsvp_status')
                            ->label('Status RSVP')
                            ->options(VipGuest::$rsvpOptions)
                            ->required()
                            ->default('menunggu')
                            ->native(false),
                    ]),

                Section::make('Riwayat RSVP')
                    ->description('Informasi audit konfirmasi kehadiran. Biasanya terisi otomatis dari aplikasi mobile.')
                    ->collapsed()
                    ->columns(2)
                    ->schema([
                        TextInput::make('rsvp_updated_by_name')
                            ->label('Diperbarui Oleh')
                            ->maxLength(255)
                            ->placeholder('Nama pengguna atau admin'),
                        DateTimePicker::make('rsvp_updated_at')
                            ->label('Diperbarui Pada')
                            ->native(false)
                            ->displayFormat('d M Y H:i'),
                    ]),

                Section::make('Catatan')
                    ->schema([
                        Textarea::make('catatan')
                            ->label('Catatan Tambahan')
                            ->rows(3)
                            ->placeholder('Kebutuhan khusus, protokol, atau informasi pendamping.')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
