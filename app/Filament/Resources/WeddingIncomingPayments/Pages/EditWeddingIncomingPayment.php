<?php

namespace App\Filament\Resources\WeddingIncomingPayments\Pages;

use App\Filament\Resources\WeddingIncomingPayments\WeddingIncomingPaymentResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditWeddingIncomingPayment extends EditRecord
{
    protected static string $resource = WeddingIncomingPaymentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
