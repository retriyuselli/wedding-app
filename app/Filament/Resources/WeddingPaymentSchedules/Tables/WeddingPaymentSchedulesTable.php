<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Tables;

use App\Models\WeddingPaymentSchedule;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class WeddingPaymentSchedulesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Customer')
                    ->searchable(),
                TextColumn::make('title')
                    ->searchable(),
                TextColumn::make('weddingEvent.jenis_acara')
                    ->label('Wedding Event')
                    ->placeholder('-')
                    ->searchable(),
                TextColumn::make('vendor_name')
                    ->label('Vendor')
                    ->searchable(),
                TextColumn::make('category')
                    ->formatStateUsing(fn (?string $state): string => WeddingPaymentSchedule::$categoryOptions[$state] ?? '-')
                    ->badge(),
                TextColumn::make('amount')
                    ->money('IDR')
                    ->sortable(),
                TextColumn::make('due_date')
                    ->label('Jatuh Tempo')
                    ->date()
                    ->sortable(),
                TextColumn::make('status')
                    ->formatStateUsing(fn (string $state): string => WeddingPaymentSchedule::$statusOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'paid' => 'success',
                        'overdue' => 'danger',
                        default => 'warning',
                    }),
                TextColumn::make('paid_at')
                    ->label('Dibayar Pada')
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
                SelectFilter::make('status')
                    ->options(WeddingPaymentSchedule::$statusOptions),
                SelectFilter::make('category')
                    ->options(WeddingPaymentSchedule::$categoryOptions),
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
