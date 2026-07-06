<?php

namespace App\Filament\Resources\WeddingIncomingPayments\Schemas;

use App\Models\WeddingIncomingPayment;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class WeddingIncomingPaymentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                TextInput::make('bank_name')
                    ->label('Bank'),
                TextInput::make('amount')
                    ->required()
                    ->numeric()
                    ->prefix('Rp')
                    ->default(0.0),
                DatePicker::make('transfer_date')
                    ->label('Tanggal Transfer')
                    ->required(),
                TextInput::make('sender_name')
                    ->label('Nama Pengirim')
                    ->required(),
                TextInput::make('description')
                    ->label('Keterangan'),
                TextInput::make('reference_number')
                    ->label('Nomor Referensi'),
                TextInput::make('proof_url')
                    ->label('URL Bukti Transfer')
                    ->url(),
                Select::make('status')
                    ->options(WeddingIncomingPayment::$statusOptions)
                    ->required()
                    ->default('menunggu'),
                DateTimePicker::make('confirmed_at')
                    ->label('Dikonfirmasi Pada'),
                TextInput::make('confirmed_by')
                    ->label('Dikonfirmasi Oleh'),
                Textarea::make('rejection_reason')
                    ->label('Alasan Penolakan')
                    ->columnSpanFull(),
                Textarea::make('notes')
                    ->columnSpanFull(),
            ]);
    }
}
