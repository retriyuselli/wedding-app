<?php

namespace App\Filament\Resources\WeddingEvents\Tables;

use App\Models\WeddingEvent;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class WeddingEventsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Customer')
                    ->searchable(),
                TextColumn::make('jenis_acara')
                    ->label('Jenis Acara')
                    ->formatStateUsing(fn (string $state): string => WeddingEvent::$jenisOptions[$state] ?? $state)
                    ->badge()
                    ->searchable(),
                TextColumn::make('tgl_acara')
                    ->label('Tanggal Acara')
                    ->date()
                    ->sortable(),
                TextColumn::make('lokasi_acara')
                    ->label('Lokasi Acara')
                    ->searchable(),
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
                SelectFilter::make('jenis_acara')
                    ->label('Jenis Acara')
                    ->options(WeddingEvent::$jenisOptions),
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
