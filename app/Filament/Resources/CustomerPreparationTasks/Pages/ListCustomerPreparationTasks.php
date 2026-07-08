<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Pages;

use App\Filament\Resources\CustomerPreparationTasks\CustomerPreparationTaskResource;
use App\Filament\Resources\CustomerPreparationTasks\Tables\CustomerPreparationTasksTable;
use Filament\Actions\Action;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;
use Filament\Tables\Table;

class ListCustomerPreparationTasks extends ListRecords
{
    protected static string $resource = CustomerPreparationTaskResource::class;

    public function table(Table $table): Table
    {
        return CustomerPreparationTasksTable::configure($table)
            ->reorderable(
                'sort_order',
                fn (): bool => filled(data_get($this->getTableFilterState('user_id'), 'value')),
            )
            ->reorderRecordsTriggerAction(
                fn (Action $action, bool $isReordering): Action => $action
                    ->label($isReordering ? 'Selesai urutkan' : 'Atur urutan')
                    ->tooltip('Filter pengantin terlebih dahulu, lalu seret baris untuk mengubah urutan.'),
            );
    }

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
