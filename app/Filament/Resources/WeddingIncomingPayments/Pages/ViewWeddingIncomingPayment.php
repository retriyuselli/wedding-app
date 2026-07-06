<?php

namespace App\Filament\Resources\WeddingIncomingPayments\Pages;

use App\Filament\Resources\WeddingIncomingPayments\WeddingIncomingPaymentResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewWeddingIncomingPayment extends ViewRecord
{
    protected static string $resource = WeddingIncomingPaymentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
