<?php

namespace App\Filament\Resources\FamilyMembers\Schemas;

use App\Models\FamilyMember;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class FamilyMemberInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('no')
                    ->label('No')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('name'),
                TextEntry::make('role')
                    ->placeholder('-'),
                TextEntry::make('phone')
                    ->placeholder('-'),
                TextEntry::make('rsvp_status')
                    ->label('RSVP')
                    ->formatStateUsing(fn (string $state): string => FamilyMember::$rsvpOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'hadir' => 'success',
                        'tidak_hadir' => 'danger',
                        default => 'warning',
                    }),
                TextEntry::make('rsvp_updated_by_name')
                    ->label('Diperbarui Oleh')
                    ->placeholder('-'),
                TextEntry::make('rsvp_updated_at')
                    ->label('RSVP Diperbarui Pada')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
