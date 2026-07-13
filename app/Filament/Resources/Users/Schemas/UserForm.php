<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Informasi Akun')
                    ->description('Data login utama yang dipakai di web dan aplikasi mobile.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('name')
                            ->label('Nama')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Nama lengkap pengantin / admin'),
                        TextInput::make('email')
                            ->label('Email')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255)
                            ->placeholder('nama@email.com'),
                        TextInput::make('whatsapp')
                            ->label('WhatsApp')
                            ->tel()
                            ->maxLength(30)
                            ->placeholder('08xxxxxxxxxx')
                            ->helperText('Nomor yang bisa dihubungi untuk konfirmasi.'),
                        Toggle::make('email_verified_at')
                            ->label('Email terverifikasi')
                            ->helperText('Aktifkan jika email sudah dikonfirmasi.')
                            ->formatStateUsing(fn (mixed $state): bool => filled($state))
                            ->dehydrateStateUsing(fn (bool $state): ?\Illuminate\Support\Carbon => $state ? now() : null)
                            ->inline(false),
                    ]),

                Section::make('Keamanan')
                    ->description('Kosongkan password saat edit jika tidak ingin mengubahnya.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('password')
                            ->label('Password')
                            ->password()
                            ->revealable()
                            ->autocomplete('new-password')
                            ->dehydrated(fn (?string $state): bool => filled($state))
                            ->required(fn (string $operation): bool => $operation === 'create')
                            ->confirmed()
                            ->helperText(fn (string $operation): string => $operation === 'edit'
                                ? 'Biarkan kosong untuk mempertahankan password saat ini.'
                                : 'Minimal sesuai kebijakan password aplikasi.'),
                        TextInput::make('password_confirmation')
                            ->label('Konfirmasi Password')
                            ->password()
                            ->revealable()
                            ->autocomplete('new-password')
                            ->dehydrated(false)
                            ->required(fn (string $operation): bool => $operation === 'create'),
                    ]),

                Section::make('Role & Akses')
                    ->description('Role menentukan akses ke panel admin dan fitur tertentu.')
                    ->schema([
                        Select::make('roles')
                            ->label('Role')
                            ->relationship('roles', 'name')
                            ->multiple()
                            ->preload()
                            ->searchable()
                            ->native(false)
                            ->helperText('Contoh: super_admin untuk akses penuh, termasuk kirim notifikasi.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Profil')
                    ->description('Avatar bisa berupa URL eksternal (Google/Apple) atau path storage.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('avatar_url')
                            ->label('URL Avatar')
                            ->url()
                            ->maxLength(2048)
                            ->placeholder('https://...')
                            ->helperText('URL lengkap atau path relatif di storage.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Login Sosial')
                    ->description('ID provider diisi otomatis saat login Google/Apple. Jangan diubah manual kecuali untuk debugging.')
                    ->columns(2)
                    ->visibleOn('edit')
                    ->collapsed()
                    ->schema([
                        TextInput::make('google_id')
                            ->label('Google ID')
                            ->disabled()
                            ->dehydrated(false)
                            ->placeholder('Belum terhubung'),
                        TextInput::make('apple_id')
                            ->label('Apple ID')
                            ->disabled()
                            ->dehydrated(false)
                            ->placeholder('Belum terhubung'),
                        DateTimePicker::make('created_at')
                            ->label('Dibuat')
                            ->disabled()
                            ->dehydrated(false),
                        DateTimePicker::make('updated_at')
                            ->label('Diperbarui')
                            ->disabled()
                            ->dehydrated(false),
                    ]),
            ]);
    }
}
