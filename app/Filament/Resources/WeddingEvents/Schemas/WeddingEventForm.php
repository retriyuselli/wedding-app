<?php

namespace App\Filament\Resources\WeddingEvents\Schemas;

use App\Models\WeddingEvent;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class WeddingEventForm
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
                Select::make('jenis_acara')
                    ->label('Jenis Acara')
                    ->options(WeddingEvent::$jenisOptions)
                    ->required(),
                DatePicker::make('tgl_acara')
                    ->label('Tanggal Acara'),
                TextInput::make('lokasi_acara')
                    ->label('Lokasi Acara'),
                TextInput::make('vendor_booking_id')
                    ->numeric(),
                Textarea::make('catatan')
                    ->columnSpanFull(),
            ]);
    }
}
