<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Pages;

use App\Filament\Resources\CustomerPreparationTasks\CustomerPreparationTaskResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListCustomerPreparationTasks extends ListRecords
{
    protected static string $resource = CustomerPreparationTaskResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
