<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Schemas;

use App\Models\WeddingPaymentSchedule;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class WeddingPaymentScheduleForm
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
                Select::make('wedding_event_id')
                    ->label('Wedding Event')
                    ->relationship('weddingEvent', 'jenis_acara')
                    ->searchable()
                    ->preload(),
                Select::make('customer_payment_method_id')
                    ->label('Metode Pembayaran')
                    ->relationship('paymentMethod', 'name')
                    ->searchable()
                    ->preload(),
                TextInput::make('title')
                    ->required(),
                TextInput::make('vendor_name')
                    ->label('Vendor'),
                Select::make('category')
                    ->options(WeddingPaymentSchedule::$categoryOptions),
                TextInput::make('amount')
                    ->required()
                    ->numeric()
                    ->prefix('Rp')
                    ->default(0.0),
                DatePicker::make('due_date')
                    ->label('Jatuh Tempo'),
                Select::make('status')
                    ->options(WeddingPaymentSchedule::$statusOptions)
                    ->required()
                    ->default('pending'),
                DateTimePicker::make('paid_at')
                    ->label('Dibayar Pada'),
                FileUpload::make('proof_url')
                    ->label('Bukti Pembayaran')
                    ->disk('public')
                    ->directory('payment-schedules/proofs')
                    ->visibility('public')
                    ->acceptedFileTypes(['image/jpeg', 'image/png'])
                    ->maxSize(1024)
                    ->downloadable()
                    ->openable(),
                Textarea::make('notes')
                    ->columnSpanFull(),
                TextInput::make('sort_order')
                    ->required()
                    ->numeric()
                    ->default(0),
            ]);
    }
}
