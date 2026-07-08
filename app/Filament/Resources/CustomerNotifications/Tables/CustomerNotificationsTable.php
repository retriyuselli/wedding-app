<?php

namespace App\Filament\Resources\CustomerNotifications\Tables;

use App\Models\CustomerNotification;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class CustomerNotificationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->striped()
            ->columns([
                TextColumn::make('title')
                    ->label('Notifikasi')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->limit(50)
                    ->description(fn (CustomerNotification $record): ?string => $record->message
                        ? str($record->message)->limit(60)->toString()
                        : null),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('group')
                    ->label('Grup')
                    ->formatStateUsing(fn (?string $state): string => $state
                        ? (CustomerNotification::$groupOptions[$state] ?? $state)
                        : '-')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'payment' => 'warning',
                        'guest' => 'info',
                        'preparation' => 'success',
                        'system' => 'gray',
                        default => 'gray',
                    })
                    ->searchable()
                    ->sortable(),
                TextColumn::make('tint')
                    ->label('Aksen')
                    ->formatStateUsing(fn (?string $state): string => $state
                        ? (CustomerNotification::$tintOptions[$state] ?? $state)
                        : '-')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'success' => 'success',
                        'warning' => 'warning',
                        'danger' => 'danger',
                        'info' => 'info',
                        default => 'gray',
                    })
                    ->toggleable(),
                IconColumn::make('is_unread')
                    ->label('Baru')
                    ->boolean()
                    ->trueIcon('heroicon-o-envelope')
                    ->falseIcon('heroicon-o-envelope-open')
                    ->trueColor('warning')
                    ->falseColor('gray'),
                TextColumn::make('destination')
                    ->label('Tujuan')
                    ->searchable()
                    ->placeholder('-')
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('icon')
                    ->label('Ikon')
                    ->placeholder('-')
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label('Dikirim')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
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
                SelectFilter::make('group')
                    ->label('Grup')
                    ->options(CustomerNotification::$groupOptions),
                SelectFilter::make('tint')
                    ->label('Aksen')
                    ->options(CustomerNotification::$tintOptions),
                TernaryFilter::make('is_unread')
                    ->label('Belum Dibaca'),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada notifikasi')
            ->emptyStateDescription('Notifikasi untuk pengantin akan muncul di sini setelah dibuat sistem atau admin.');
    }
}
