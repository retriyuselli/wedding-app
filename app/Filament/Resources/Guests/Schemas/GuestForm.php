<?php

namespace App\Filament\Resources\Guests\Schemas;

use App\Models\Guest;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class GuestForm
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
                TextInput::make('name')
                    ->required(),
                TextInput::make('phone')
                    ->tel(),
                TextInput::make('email')
                    ->label('Email address')
                    ->email(),
                TextInput::make('table_number')
                    ->label('Nomor Meja'),
                Select::make('rsvp_status')
                    ->label('RSVP')
                    ->options(Guest::$rsvpOptions)
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
