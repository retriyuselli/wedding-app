<?php

namespace App\Filament\Resources\WeddingInfos\Tables;

use App\Models\WeddingInfo;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class WeddingInfosTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query
                ->withCount(['events', 'familyMembers']))
            ->defaultSort('updated_at', 'desc')
            ->striped()
            ->columns([
                TextColumn::make('couple_names')
                    ->label('Pasangan')
                    ->searchable(['groom_name', 'bride_name'])
                    ->weight('medium')
                    ->description(fn (WeddingInfo $record): ?string => $record->budaya),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('groom_name')
                    ->label('Mempelai Pria')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('bride_name')
                    ->label('Mempelai Wanita')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('budaya')
                    ->label('Budaya / Tema')
                    ->searchable()
                    ->badge()
                    ->color('info')
                    ->placeholder('-'),
                TextColumn::make('songlist_count')
                    ->label('Lagu')
                    ->state(fn (WeddingInfo $record): int => count($record->songlist ?? []))
                    ->badge()
                    ->color('gray'),
                TextColumn::make('events_count')
                    ->label('Acara')
                    ->sortable()
                    ->badge()
                    ->color('gray'),
                TextColumn::make('family_members_count')
                    ->label('Keluarga')
                    ->sortable()
                    ->badge()
                    ->color('gray')
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->label('Diperbarui')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('user_id')
                    ->label('Pengantin')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload(),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada info pernikahan')
            ->emptyStateDescription('Tambahkan profil pernikahan untuk pengantin atau tunggu input dari aplikasi mobile.');
    }
}
