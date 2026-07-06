<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Pages;

use App\Filament\Resources\CustomerPreparationTasks\CustomerPreparationTaskResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewCustomerPreparationTask extends ViewRecord
{
    protected static string $resource = CustomerPreparationTaskResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
