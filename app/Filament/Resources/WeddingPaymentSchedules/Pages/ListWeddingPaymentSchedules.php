<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Pages;

use App\Filament\Resources\WeddingPaymentSchedules\WeddingPaymentScheduleResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListWeddingPaymentSchedules extends ListRecords
{
    protected static string $resource = WeddingPaymentScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
