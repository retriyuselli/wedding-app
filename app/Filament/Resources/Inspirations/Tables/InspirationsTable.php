<?php

namespace App\Filament\Resources\Inspirations\Tables;

use App\Models\Inspiration;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class InspirationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('sort_order')
            ->description('Urutan inspirasi diatur otomatis. Gunakan tombol "Atur urutan" untuk drag & drop.')
            ->reorderable('sort_order')
            ->columns([
                ImageColumn::make('image_url')
                    ->label('Gambar')
                    ->disk('public')
                    ->square(),
                TextColumn::make('title')
                    ->label('Judul')
                    ->searchable()
                    ->sortable()
                    ->limit(40)
                    ->wrap(),
                TextColumn::make('category')
                    ->label('Kategori')
                    ->formatStateUsing(fn (?string $state): string => Inspiration::$categoryOptions[$state] ?? ($state ?? '-'))
                    ->badge()
                    ->sortable()
                    ->searchable(),
                TextColumn::make('likes_count')
                    ->label('Suka')
                    ->numeric()
                    ->sortable(),
                TextColumn::make('views_count')
                    ->label('Dilihat')
                    ->numeric()
                    ->sortable(),
                IconColumn::make('is_active')
                    ->label('Aktif')
                    ->boolean(),
                TextColumn::make('sort_order')
                    ->label('Urutan')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('thumbnail_symbol')
                    ->label('Ikon')
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->label('Diperbarui')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('category')
                    ->label('Kategori')
                    ->options(Inspiration::$categoryOptions),
                TernaryFilter::make('is_active')
                    ->label('Aktif'),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
