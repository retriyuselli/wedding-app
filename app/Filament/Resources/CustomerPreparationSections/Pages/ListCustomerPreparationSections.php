<?php

namespace App\Filament\Resources\CustomerPreparationSections\Pages;

use App\Filament\Resources\CustomerPreparationSections\CustomerPreparationSectionResource;
use App\Filament\Resources\CustomerPreparationSections\Tables\CustomerPreparationSectionsTable;
use Filament\Actions\Action;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;
use Filament\Tables\Table;

class ListCustomerPreparationSections extends ListRecords
{
    protected static string $resource = CustomerPreparationSectionResource::class;

    public function table(Table $table): Table
    {
        return CustomerPreparationSectionsTable::configure($table)
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
