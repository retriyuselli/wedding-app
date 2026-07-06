<?php

namespace App\Filament\Resources\CustomerPreparationSections\Pages;

use App\Filament\Resources\CustomerPreparationSections\CustomerPreparationSectionResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditCustomerPreparationSection extends EditRecord
{
    protected static string $resource = CustomerPreparationSectionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
