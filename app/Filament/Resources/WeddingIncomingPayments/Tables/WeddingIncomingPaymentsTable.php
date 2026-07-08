<?php

namespace App\Filament\Resources\WeddingIncomingPayments\Tables;

use App\Models\WeddingIncomingPayment;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class WeddingIncomingPaymentsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('transfer_date', 'desc')
            ->striped()
            ->columns([
                TextColumn::make('sender_name')
                    ->label('Pengirim')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (WeddingIncomingPayment $record): ?string => $record->bank_name),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('amount')
                    ->label('Nominal')
                    ->money('IDR')
                    ->sortable()
                    ->alignEnd(),
                TextColumn::make('transfer_date')
                    ->label('Tanggal Transfer')
                    ->date('d M Y')
                    ->sortable(),
                TextColumn::make('status')
                    ->label('Status')
                    ->formatStateUsing(fn (string $state): string => WeddingIncomingPayment::$statusOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'confirmed' => 'success',
                        'rejected' => 'danger',
                        default => 'warning',
                    })
                    ->sortable(),
                TextColumn::make('reference_number')
                    ->label('Referensi')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('description')
                    ->label('Keterangan')
                    ->limit(40)
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('confirmed_at')
                    ->label('Dikonfirmasi')
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
                SelectFilter::make('status')
                    ->label('Status')
                    ->options(WeddingIncomingPayment::$statusOptions),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada uang masuk')
            ->emptyStateDescription('Tambahkan data uang masuk dari customer atau tunggu input dari aplikasi mobile.');
    }
}
