<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Pages;

use App\Filament\Resources\WeddingPaymentSchedules\Tables\WeddingPaymentSchedulesTable;
use App\Filament\Resources\WeddingPaymentSchedules\WeddingPaymentScheduleResource;
use Filament\Actions\Action;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;
use Filament\Tables\Table;

class ListWeddingPaymentSchedules extends ListRecords
{
    protected static string $resource = WeddingPaymentScheduleResource::class;

    public function table(Table $table): Table
    {
        return WeddingPaymentSchedulesTable::configure($table)
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
