<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Pages;

use App\Filament\Resources\CustomerPaymentMethods\CustomerPaymentMethodResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewCustomerPaymentMethod extends ViewRecord
{
    protected static string $resource = CustomerPaymentMethodResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
