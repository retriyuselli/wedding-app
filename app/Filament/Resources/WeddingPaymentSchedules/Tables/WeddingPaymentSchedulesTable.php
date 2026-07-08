<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Tables;

use App\Models\WeddingPaymentSchedule;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class WeddingPaymentSchedulesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('due_date')
            ->description('Urutan manual diatur otomatis. Filter pengantin lalu gunakan tombol "Atur urutan" untuk drag & drop.')
            ->striped()
            ->columns([
                TextColumn::make('title')
                    ->label('Expense')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (WeddingPaymentSchedule $record): ?string => $record->vendor_name),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('category')
                    ->label('Kategori')
                    ->formatStateUsing(fn (?string $state): string => WeddingPaymentSchedule::$categoryOptions[$state] ?? ($state ?? '-'))
                    ->badge()
                    ->sortable(),
                TextColumn::make('amount')
                    ->label('Nominal')
                    ->money('IDR')
                    ->sortable()
                    ->alignEnd(),
                TextColumn::make('due_date')
                    ->label('Jatuh Tempo')
                    ->date('d M Y')
                    ->sortable(),
                TextColumn::make('status')
                    ->label('Status')
                    ->formatStateUsing(fn (string $state): string => WeddingPaymentSchedule::$statusOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'paid' => 'success',
                        'overdue' => 'danger',
                        default => 'warning',
                    })
                    ->sortable(),
                TextColumn::make('weddingEvent.jenis_acara')
                    ->label('Acara')
                    ->placeholder('-')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                IconColumn::make('proof_url')
                    ->label('Bukti')
                    ->boolean()
                    ->trueIcon('heroicon-o-paper-clip')
                    ->falseIcon('heroicon-o-minus')
                    ->getStateUsing(fn (WeddingPaymentSchedule $record): bool => filled($record->proof_url))
                    ->toggleable(),
                TextColumn::make('paid_at')
                    ->label('Dibayar')
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
                SelectFilter::make('status')
                    ->label('Status')
                    ->options(WeddingPaymentSchedule::$statusOptions),
                SelectFilter::make('category')
                    ->label('Kategori')
                    ->options(WeddingPaymentSchedule::$categoryOptions),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada jadwal pembayaran')
            ->emptyStateDescription('Tambahkan expense manual atau tunggu input dari aplikasi mobile.');
    }
}
