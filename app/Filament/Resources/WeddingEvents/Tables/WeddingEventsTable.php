<?php

namespace App\Filament\Resources\WeddingEvents\Tables;

use App\Models\WeddingEvent;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class WeddingEventsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query
                ->withCount(['preparationTasks', 'paymentSchedules']))
            ->defaultSort('sort_order')
            ->striped()
            ->columns([
                TextColumn::make('jenis_acara')
                    ->label('Acara')
                    ->formatStateUsing(fn (string $state): string => WeddingEvent::$jenisOptions[$state] ?? $state)
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'akad' => 'success',
                        'resepsi' => 'warning',
                        'lamaran' => 'info',
                        default => 'gray',
                    })
                    ->description(fn (WeddingEvent $record): ?string => $record->lokasi_acara),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('sort_order')
                    ->label('Urutan')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('tgl_acara')
                    ->label('Tanggal')
                    ->date('d M Y')
                    ->sortable()
                    ->placeholder('-'),
                TextColumn::make('preparation_tasks_count')
                    ->label('Tugas')
                    ->sortable()
                    ->badge()
                    ->color('gray'),
                TextColumn::make('payment_schedules_count')
                    ->label('Expense')
                    ->sortable()
                    ->badge()
                    ->color('gray'),
                TextColumn::make('lokasi_acara')
                    ->label('Lokasi')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('vendor_booking_id')
                    ->label('Booking Vendor')
                    ->placeholder('-')
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
                SelectFilter::make('jenis_acara')
                    ->label('Jenis Acara')
                    ->options(WeddingEvent::$jenisOptions),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada acara pernikahan')
            ->emptyStateDescription('Tambahkan acara seperti lamaran, akad, atau resepsi untuk pengantin.');
    }
}
