<?php

namespace App\Filament\Resources\MessageThreads\Tables;

use App\Enums\SupportMessageTopic;
use App\Models\MessageThread;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class MessageThreadsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('updated_at', 'desc')
            ->striped()
            ->columns([
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable()
                    ->description(fn (MessageThread $record): ?string => $record->user?->email),
                TextColumn::make('latestMessage.body')
                    ->label('Pesan Terakhir')
                    ->limit(60)
                    ->placeholder('Belum ada pesan')
                    ->wrap(),
                TextColumn::make('latestMessage.topic')
                    ->label('Topik')
                    ->formatStateUsing(fn (?string $state): string => $state
                        ? (SupportMessageTopic::tryFrom($state)?->label() ?? $state)
                        : '-')
                    ->badge()
                    ->color('gray')
                    ->toggleable(),
                TextColumn::make('latestMessage.is_outgoing')
                    ->label('Status')
                    ->formatStateUsing(fn (?bool $state): string => match ($state) {
                        true => 'Menunggu balasan',
                        false => 'Sudah dibalas',
                        default => 'Belum ada pesan',
                    })
                    ->badge()
                    ->color(fn (?bool $state): string => match ($state) {
                        true => 'warning',
                        false => 'success',
                        default => 'gray',
                    }),
                TextColumn::make('updated_at')
                    ->label('Terakhir Aktif')
                    ->since()
                    ->sortable(),
                TextColumn::make('is_online')
                    ->label('Online')
                    ->badge()
                    ->formatStateUsing(fn (bool $state): string => $state ? 'Online' : 'Offline')
                    ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('user_id')
                    ->label('Pengantin')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload(),
                TernaryFilter::make('awaiting_reply')
                    ->label('Menunggu Balasan')
                    ->queries(
                        true: fn ($query) => $query->whereHas('latestMessage', fn ($query) => $query->where('is_outgoing', true)),
                        false: fn ($query) => $query->whereHas('latestMessage', fn ($query) => $query->where('is_outgoing', false)),
                        blank: fn ($query) => $query,
                    ),
            ])
            ->recordActions([
                EditAction::make()
                    ->label('Buka & Balas'),
            ])
            ->emptyStateHeading('Belum ada pesan support')
            ->emptyStateDescription('Percakapan support dari pengantin akan muncul di sini setelah mereka mengirim pesan dari aplikasi.');
    }
}
