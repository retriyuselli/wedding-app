<?php

namespace App\Filament\Resources\CustomerNotifications\Schemas;

use App\Models\CustomerNotification;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class CustomerNotificationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(1)
            ->components([
                Section::make('Penerima')
                    ->description('Pilih satu pengantin, atau kirim ke semua user sekaligus (hanya saat membuat).')
                    ->schema([
                        Toggle::make('send_to_all')
                            ->label('Kirim ke semua user')
                            ->helperText('Setiap akun akan menerima salinan notifikasi yang sama di inbox aplikasi.')
                            ->default(false)
                            ->live()
                            ->visibleOn('create')
                            ->inline(false),
                        Select::make('user_id')
                            ->label('Pengantin')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->native(false)
                            ->required(fn (Get $get): bool => ! (bool) $get('send_to_all'))
                            ->visible(fn (Get $get, string $operation): bool => $operation === 'edit' || ! (bool) $get('send_to_all'))
                            ->helperText('Wajib dipilih jika tidak mengirim ke semua user.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Konten Notifikasi')
                    ->description('Judul dan pesan yang muncul di pusat notifikasi aplikasi mobile.')
                    ->schema([
                        Select::make('group')
                            ->label('Grup')
                            ->options(CustomerNotification::$groupOptions)
                            ->searchable()
                            ->native(false)
                            ->placeholder('Pilih kategori notifikasi'),
                        TextInput::make('title')
                            ->label('Judul')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Pembayaran jatuh tempo, Tamu baru konfirmasi, ...')
                            ->columnSpanFull(),
                        Textarea::make('message')
                            ->label('Pesan')
                            ->rows(3)
                            ->placeholder('Isi notifikasi yang ditampilkan ke pengantin.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Tampilan di Aplikasi')
                    ->description('Pengaturan visual dan navigasi saat notifikasi diketuk.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('icon')
                            ->label('Ikon SF Symbol')
                            ->maxLength(255)
                            ->placeholder('bell.fill, creditcard, person.2, ...')
                            ->helperText('Nama ikon SF Symbol. Kosongkan untuk ikon default.'),
                        Select::make('tint')
                            ->label('Warna Aksen')
                            ->options(CustomerNotification::$tintOptions)
                            ->native(false)
                            ->placeholder('Pilih warna'),
                        TextInput::make('destination')
                            ->label('Tujuan Navigasi')
                            ->maxLength(255)
                            ->placeholder('budget, guests, checklist, ...')
                            ->helperText('Route atau deep link di aplikasi saat notifikasi diketuk.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Status')
                    ->schema([
                        Toggle::make('is_unread')
                            ->label('Tandai belum dibaca')
                            ->helperText('Notifikasi belum dibaca akan ditampilkan dengan indikator baru di aplikasi.')
                            ->default(true)
                            ->inline(false),
                    ]),
            ]);
    }
}
