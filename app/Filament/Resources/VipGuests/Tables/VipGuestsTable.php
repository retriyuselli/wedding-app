<?php

namespace App\Filament\Resources\VipGuests\Tables;

use App\Models\VipGuest;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class VipGuestsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Customer')
                    ->searchable(),
                TextColumn::make('no')
                    ->label('No')
                    ->numeric()
                    ->sortable(),
                TextColumn::make('name')
                    ->searchable(),
                TextColumn::make('jabatan')
                    ->searchable(),
                TextColumn::make('instansi')
                    ->searchable(),
                TextColumn::make('phone')
                    ->searchable(),
                TextColumn::make('kategori')
                    ->formatStateUsing(fn (string $state): string => VipGuest::$kategoriOptions[$state] ?? $state)
                    ->badge(),
                TextColumn::make('rsvp_status')
                    ->label('RSVP')
                    ->formatStateUsing(fn (string $state): string => VipGuest::$rsvpOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'hadir' => 'success',
                        'tidak_hadir' => 'danger',
                        default => 'warning',
                    }),
                TextColumn::make('rsvp_updated_at')
                    ->label('RSVP Diperbarui Pada')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('kategori')
                    ->options(VipGuest::$kategoriOptions),
                SelectFilter::make('rsvp_status')
                    ->label('RSVP')
                    ->options(VipGuest::$rsvpOptions),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
