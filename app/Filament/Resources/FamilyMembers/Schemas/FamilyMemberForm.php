<?php

namespace App\Filament\Resources\FamilyMembers\Schemas;

use App\Models\FamilyMember;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class FamilyMemberForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Customer')
                    ->description('Pilih pengantin yang memiliki daftar anggota keluarga ini.')
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

                Section::make('Identitas Anggota')
                    ->description('Data anggota keluarga inti yang ditampilkan di daftar tamu keluarga.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('no')
                            ->label('Nomor Urut')
                            ->numeric()
                            ->minValue(1)
                            ->placeholder('1, 2, 3, ...')
                            ->helperText('Opsional. Urutan tampil di daftar keluarga.'),
                        TextInput::make('name')
                            ->label('Nama Lengkap')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Nama anggota keluarga')
                            ->columnSpanFull(),
                        TextInput::make('role')
                            ->label('Peran / Hubungan')
                            ->maxLength(255)
                            ->placeholder('Ayah, Ibu, Kakak, Adik, ...')
                            ->helperText('Hubungan keluarga terhadap pengantin.')
                            ->columnSpanFull(),
                        TextInput::make('phone')
                            ->label('Telepon / WhatsApp')
                            ->tel()
                            ->maxLength(255)
                            ->placeholder('08xxxxxxxxxx')
                            ->columnSpanFull(),
                    ]),

                Section::make('RSVP')
                    ->schema([
                        Select::make('rsvp_status')
                            ->label('Status RSVP')
                            ->options(FamilyMember::$rsvpOptions)
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
            ]);
    }
}
