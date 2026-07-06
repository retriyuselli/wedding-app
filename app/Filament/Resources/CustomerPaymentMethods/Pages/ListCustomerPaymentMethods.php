<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Pages;

use App\Filament\Resources\CustomerPaymentMethods\CustomerPaymentMethodResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListCustomerPaymentMethods extends ListRecords
{
    protected static string $resource = CustomerPaymentMethodResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
