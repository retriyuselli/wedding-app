<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Pages;

use App\Filament\Resources\CustomerPaymentMethods\CustomerPaymentMethodResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditCustomerPaymentMethod extends EditRecord
{
    protected static string $resource = CustomerPaymentMethodResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
