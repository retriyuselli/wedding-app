<?php

namespace App\Filament\Resources\VipGuests\Schemas;

use App\Models\VipGuest;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class VipGuestForm
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
                TextInput::make('no')
                    ->label('No')
                    ->numeric(),
                TextInput::make('name')
                    ->required(),
                TextInput::make('jabatan'),
                TextInput::make('instansi'),
                TextInput::make('phone')
                    ->tel(),
                Select::make('kategori')
                    ->options(VipGuest::$kategoriOptions)
                    ->required()
                    ->default('vip'),
                Select::make('rsvp_status')
                    ->label('RSVP')
                    ->options(VipGuest::$rsvpOptions)
                    ->required()
                    ->default('menunggu'),
                TextInput::make('rsvp_updated_by_name')
                    ->label('Diperbarui Oleh'),
                DateTimePicker::make('rsvp_updated_at')
                    ->label('RSVP Diperbarui Pada'),
                Textarea::make('catatan')
                    ->columnSpanFull(),
            ]);
    }
}
