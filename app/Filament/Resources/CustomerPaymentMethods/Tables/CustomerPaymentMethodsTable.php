<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Tables;

use App\Models\CustomerPaymentMethod;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class CustomerPaymentMethodsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('name')
            ->striped()
            ->columns([
                TextColumn::make('name')
                    ->label('Metode')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (CustomerPaymentMethod $record): ?string => $record->account_number),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('type')
                    ->label('Jenis')
                    ->formatStateUsing(fn (?string $state): string => CustomerPaymentMethod::$typeOptions[$state] ?? ($state ?? '-'))
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'bank' => 'info',
                        'e-wallet' => 'success',
                        'cash' => 'warning',
                        default => 'gray',
                    })
                    ->sortable(),
                TextColumn::make('account_name')
                    ->label('Atas Nama')
                    ->searchable()
                    ->toggleable(),
                IconColumn::make('is_primary')
                    ->label('Utama')
                    ->boolean()
                    ->trueIcon('heroicon-o-star')
                    ->falseIcon('heroicon-o-minus')
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('type')
                    ->label('Jenis')
                    ->options(CustomerPaymentMethod::$typeOptions),
                TernaryFilter::make('is_primary')
                    ->label('Metode Utama'),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada metode pembayaran')
            ->emptyStateDescription('Tambahkan rekening bank atau e-wallet untuk customer.');
    }
}
