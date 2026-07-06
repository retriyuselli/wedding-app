<?php

namespace App\Filament\Resources\CustomerPreparationSections\Pages;

use App\Filament\Resources\CustomerPreparationSections\CustomerPreparationSectionResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListCustomerPreparationSections extends ListRecords
{
    protected static string $resource = CustomerPreparationSectionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
