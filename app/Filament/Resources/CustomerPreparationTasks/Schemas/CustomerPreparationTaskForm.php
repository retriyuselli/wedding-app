<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Schemas;

use App\Models\CustomerPreparationTask;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class CustomerPreparationTaskForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                Select::make('wedding_event_id')
                    ->label('Wedding Event')
                    ->relationship('weddingEvent', 'jenis_acara')
                    ->searchable()
                    ->preload(),
                Select::make('section_id')
                    ->label('Section')
                    ->relationship('section', 'title')
                    ->searchable()
                    ->preload(),
                TextInput::make('title')
                    ->required(),
                TextInput::make('label'),
                Textarea::make('description')
                    ->label('Deskripsi')
                    ->rows(3)
                    ->columnSpanFull(),
                Textarea::make('notes')
                    ->label('Catatan')
                    ->rows(3)
                    ->columnSpanFull(),
                Select::make('priority')
                    ->label('Prioritas')
                    ->options(CustomerPreparationTask::$priorityOptions)
                    ->default('medium')
                    ->required(),
                Select::make('status')
                    ->options(CustomerPreparationTask::$statusOptions)
                    ->required()
                    ->default('pending'),
                DatePicker::make('due_date')
                    ->label('Jatuh Tempo'),
                TextInput::make('sort_order')
                    ->label('Urutan')
                    ->required()
                    ->numeric()
                    ->default(0),
                Repeater::make('subTasks')
                    ->relationship()
                    ->label('Sub Tugas')
                    ->schema([
                        TextInput::make('title')
                            ->required(),
                        Select::make('status')
                            ->options(CustomerPreparationTask::$statusOptions)
                            ->default('pending')
                            ->required(),
                        DatePicker::make('due_date')
                            ->label('Target'),
                        DatePicker::make('completed_at')
                            ->label('Selesai Pada'),
                        TextInput::make('sort_order')
                            ->label('Urutan')
                            ->numeric()
                            ->default(0),
                    ])
                    ->columns(2)
                    ->columnSpanFull()
                    ->orderColumn('sort_order')
                    ->collapsible(),
            ]);
    }
}
