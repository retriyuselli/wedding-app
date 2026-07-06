<?php

namespace App\Filament\Resources\FamilyMembers\Schemas;

use App\Models\FamilyMember;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class FamilyMemberForm
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
                TextInput::make('role'),
                TextInput::make('phone')
                    ->tel(),
                Select::make('rsvp_status')
                    ->label('RSVP')
                    ->options(FamilyMember::$rsvpOptions)
                    ->required()
                    ->default('menunggu'),
                TextInput::make('rsvp_updated_by_name')
                    ->label('Diperbarui Oleh'),
                DateTimePicker::make('rsvp_updated_at')
                    ->label('RSVP Diperbarui Pada'),
            ]);
    }
}
