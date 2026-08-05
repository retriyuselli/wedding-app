<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Pages;

use App\Filament\Resources\CustomerPaymentMethods\CustomerPaymentMethodResource;
use Filament\Resources\Pages\CreateRecord;

class CreateCustomerPaymentMethod extends CreateRecord
{
    protected static string $resource = CustomerPaymentMethodResource::class;
}
