<?php

namespace App\Filament\Resources\CustomerPreparationTasks\Pages;

use App\Filament\Resources\CustomerPreparationTasks\CustomerPreparationTaskResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditCustomerPreparationTask extends EditRecord
{
    protected static string $resource = CustomerPreparationTaskResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
