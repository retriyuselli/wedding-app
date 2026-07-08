<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Tables;

use App\Models\CustomerPreparationTask;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CustomerPreparationTasksTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('sort_order')
            ->description('Urutan tugas diatur otomatis. Filter pengantin lalu gunakan tombol "Atur urutan" untuk drag & drop.')
            ->striped()
            ->columns([
                TextColumn::make('title')
                    ->label('Tugas')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (CustomerPreparationTask $record): ?string => $record->label),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('section.title')
                    ->label('Bagian')
                    ->placeholder('-')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('priority')
                    ->label('Prioritas')
                    ->formatStateUsing(fn (string $state): string => CustomerPreparationTask::$priorityOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'high' => 'danger',
                        'medium' => 'warning',
                        default => 'gray',
                    })
                    ->sortable(),
                TextColumn::make('status')
                    ->label('Status')
                    ->formatStateUsing(fn (string $state): string => CustomerPreparationTask::$statusOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'done' => 'success',
                        'in_progress' => 'info',
                        default => 'gray',
                    })
                    ->sortable(),
                TextColumn::make('sub_tasks_count')
                    ->label('Sub Tugas')
                    ->counts('subTasks')
                    ->sortable()
                    ->badge()
                    ->color('gray'),
                TextColumn::make('due_date')
                    ->label('Jatuh Tempo')
                    ->date('d M Y')
                    ->sortable()
                    ->placeholder('-'),
                TextColumn::make('weddingEvent.jenis_acara')
                    ->label('Acara')
                    ->placeholder('-')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->label('Diperbarui')
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
                SelectFilter::make('section_id')
                    ->label('Bagian')
                    ->relationship('section', 'title')
                    ->searchable()
                    ->preload(),
                SelectFilter::make('status')
                    ->label('Status')
                    ->options(CustomerPreparationTask::$statusOptions),
                SelectFilter::make('priority')
                    ->label('Prioritas')
                    ->options(CustomerPreparationTask::$priorityOptions),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada tugas checklist')
            ->emptyStateDescription('Tambahkan tugas persiapan untuk pengantin atau kelola dari aplikasi mobile.');
    }
}
