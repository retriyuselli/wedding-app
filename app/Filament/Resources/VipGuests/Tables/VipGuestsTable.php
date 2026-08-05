<?php

namespace App\Filament\Resources\VipGuests\Tables;

use App\Models\VipGuest;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class VipGuestsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('no')
            ->striped()
            ->columns([
                TextColumn::make('no')
                    ->label('No')
                    ->numeric()
                    ->sortable()
                    ->placeholder('-')
                    ->alignCenter(),
                TextColumn::make('name')
                    ->label('Nama Tamu')
                    ->searchable()
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (VipGuest $record): ?string => collect([$record->jabatan, $record->instansi])
                        ->filter()
                        ->implode(' · ')
                        ?: null),
                TextColumn::make('user.name')
                    ->label('Pengantin')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('kategori')
                    ->label('Kategori')
                    ->formatStateUsing(fn (string $state): string => VipGuest::$kategoriOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'vip' => 'warning',
                        'pejabat' => 'info',
                        'keluarga_besar' => 'success',
                        default => 'gray',
                    })
                    ->sortable(),
                TextColumn::make('rsvp_status')
                    ->label('RSVP')
                    ->formatStateUsing(fn (string $state): string => VipGuest::$rsvpOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'hadir' => 'success',
                        'tidak_hadir' => 'danger',
                        default => 'warning',
                    })
                    ->sortable(),
                TextColumn::make('phone')
                    ->label('Telepon')
                    ->searchable()
                    ->placeholder('-')
                    ->toggleable(),
                TextColumn::make('jabatan')
                    ->label('Jabatan')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('instansi')
                    ->label('Instansi')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('rsvp_updated_at')
                    ->label('RSVP Diperbarui')
                    ->dateTime('d M Y H:i')
                    ->sortable()
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
                SelectFilter::make('kategori')
                    ->label('Kategori')
                    ->options(VipGuest::$kategoriOptions),
                SelectFilter::make('rsvp_status')
                    ->label('RSVP')
                    ->options(VipGuest::$rsvpOptions),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Belum ada tamu VIP')
            ->emptyStateDescription('Tambahkan tamu VIP untuk daftar undangan khusus pengantin.');
    }
}
