<?php

namespace App\Filament\Resources\CustomerPreparationSections\Pages;

use App\Filament\Resources\CustomerPreparationSections\CustomerPreparationSectionResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewCustomerPreparationSection extends ViewRecord
{
    protected static string $resource = CustomerPreparationSectionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
