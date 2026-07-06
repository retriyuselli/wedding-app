<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Schemas;

use App\Models\CustomerPreparationTask;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class CustomerPreparationTaskInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('weddingEvent.jenis_acara')
                    ->label('Wedding Event')
                    ->placeholder('-'),
                TextEntry::make('section.title')
                    ->label('Section')
                    ->placeholder('-'),
                TextEntry::make('title'),
                TextEntry::make('label')
                    ->placeholder('-'),
                TextEntry::make('status')
                    ->formatStateUsing(fn (string $state): string => CustomerPreparationTask::$statusOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'done' => 'success',
                        'in_progress' => 'info',
                        default => 'gray',
                    }),
                TextEntry::make('due_date')
                    ->label('Jatuh Tempo')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
