<?php

namespace App\Filament\Resources\WeddingIncomingPayments\Pages;

use App\Filament\Resources\WeddingIncomingPayments\WeddingIncomingPaymentResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListWeddingIncomingPayments extends ListRecords
{
    protected static string $resource = WeddingIncomingPaymentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
