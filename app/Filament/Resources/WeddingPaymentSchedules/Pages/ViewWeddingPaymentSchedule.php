<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Pages;

use App\Filament\Resources\WeddingPaymentSchedules\WeddingPaymentScheduleResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewWeddingPaymentSchedule extends ViewRecord
{
    protected static string $resource = WeddingPaymentScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
