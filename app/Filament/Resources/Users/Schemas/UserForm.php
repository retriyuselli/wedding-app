<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Filament\Schemas\Schema;
use Illuminate\Support\Carbon;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        $proProductOptions = collect(config('billing.pro_product_ids', ['wedding_pro_unlock']))
            ->mapWithKeys(fn (string $id): array => [$id => $id])
            ->all();

        $defaultProProductId = array_key_first($proProductOptions) ?: 'wedding_pro_unlock';

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
                            ->dehydrateStateUsing(fn (bool $state): ?Carbon => $state ? now() : null)
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

                Section::make('Wedding Pro')
                    ->description('Status Premium Non-Consumable di app (IAP wedding_pro_unlock). Bisa diaktifkan manual untuk demo / App Review.')
                    ->columns(2)
                    ->schema([
                        Toggle::make('is_premium')
                            ->label('Wedding Pro aktif')
                            ->helperText('Jika aktif, Checklist / Tamu / Budget terbuka tanpa paywall.')
                            ->live()
                            ->afterStateUpdated(function (bool $state, Set $set, Get $get) use ($defaultProProductId): void {
                                if ($state) {
                                    if (blank($get('premium_product_id'))) {
                                        $set('premium_product_id', $defaultProProductId);
                                    }

                                    if (blank($get('premium_activated_at'))) {
                                        $set('premium_activated_at', now());
                                    }

                                    return;
                                }

                                $set('premium_product_id', null);
                                $set('premium_activated_at', null);
                                $set('apple_original_transaction_id', null);
                            })
                            ->inline(false),
                        Select::make('premium_product_id')
                            ->label('Product ID')
                            ->options($proProductOptions)
                            ->native(false)
                            ->searchable()
                            ->placeholder('Pilih product IAP')
                            ->visible(fn (Get $get): bool => (bool) $get('is_premium'))
                            ->required(fn (Get $get): bool => (bool) $get('is_premium'))
                            ->helperText('Harus cocok dengan App Store Connect.'),
                        DateTimePicker::make('premium_activated_at')
                            ->label('Aktif sejak')
                            ->seconds(false)
                            ->native(false)
                            ->visible(fn (Get $get): bool => (bool) $get('is_premium'))
                            ->required(fn (Get $get): bool => (bool) $get('is_premium')),
                        TextInput::make('apple_original_transaction_id')
                            ->label('Apple original transaction ID')
                            ->maxLength(255)
                            ->placeholder('Kosongkan jika aktivasi manual')
                            ->helperText('Diisi otomatis dari IAP. Untuk demo boleh diisi ID fiktif unik.')
                            ->visible(fn (Get $get): bool => (bool) $get('is_premium'))
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
