<?php

namespace App\Filament\Resources\CustomerPreparationSections\Tables;

use App\Models\CustomerPreparationSection;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CustomerPreparationSectionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('sort_order')
            ->description('Urutan bagian diatur otomatis. Filter pengantin lalu gunakan tombol "Atur urutan" untuk drag & drop.')
            ->striped()
            ->columns([
                TextColumn::make('title')
                    ->label('Bagian')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (CustomerPreparationSection $record): ?string => $record->icon),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('tasks_count')
                    ->label('Tugas')
                    ->counts('tasks')
                    ->sortable()
                    ->badge()
                    ->color('gray'),
                TextColumn::make('icon')
                    ->label('Ikon')
                    ->formatStateUsing(fn (?string $state): string => CustomerPreparationSection::$iconOptions[$state] ?? ($state ?? '-'))
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('sort_order')
                    ->label('Urutan')
                    ->numeric()
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
            ->emptyStateHeading('Belum ada bagian checklist')
            ->emptyStateDescription('Tambahkan section persiapan untuk mengelompokkan tugas checklist.');
    }
}
