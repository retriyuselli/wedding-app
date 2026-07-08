<?php

namespace App\Filament\Resources\WeddingBudgets\Tables;

use App\Models\WeddingBudget;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class WeddingBudgetsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query
                ->withSum('paymentSchedules as total_spent', 'amount')
                ->withCount(['paymentSchedules', 'incomingPayments', 'categoryAllocations']))
            ->defaultSort('updated_at', 'desc')
            ->striped()
            ->columns([
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (WeddingBudget $record): ?string => $record->notes ? str($record->notes)->limit(50)->toString() : null),
                TextColumn::make('total_budget')
                    ->label('Total Anggaran')
                    ->money(fn (WeddingBudget $record): string => $record->currency ?? WeddingBudget::defaultCurrency())
                    ->sortable()
                    ->alignEnd(),
                TextColumn::make('total_spent')
                    ->label('Terpakai')
                    ->money('IDR')
                    ->sortable()
                    ->alignEnd()
                    ->placeholder('Rp 0'),
                TextColumn::make('remaining_budget')
                    ->label('Sisa')
                    ->money('IDR')
                    ->alignEnd()
                    ->state(fn (WeddingBudget $record): float => max(0, (float) $record->total_budget - (float) ($record->total_spent ?? 0)))
                    ->color(fn (WeddingBudget $record): string => (float) $record->total_budget > 0
                        && (float) ($record->total_spent ?? 0) > (float) $record->total_budget
                        ? 'danger'
                        : 'success'),
                TextColumn::make('payment_schedules_count')
                    ->label('Expense')
                    ->sortable()
                    ->badge()
                    ->color('gray'),
                TextColumn::make('incoming_payments_count')
                    ->label('Uang Masuk')
                    ->sortable()
                    ->badge()
                    ->color('gray'),
                TextColumn::make('category_allocations_count')
                    ->label('Alokasi')
                    ->sortable()
                    ->badge()
                    ->color('gray')
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('currency')
                    ->label('Mata Uang')
                    ->badge()
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
            ->emptyStateHeading('Belum ada anggaran pernikahan')
            ->emptyStateDescription('Tambahkan anggaran untuk pengantin atau tunggu input dari aplikasi mobile.');
    }
}
