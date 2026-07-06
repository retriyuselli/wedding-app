<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Pages;

use App\Filament\Resources\WeddingPaymentSchedules\WeddingPaymentScheduleResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditWeddingPaymentSchedule extends EditRecord
{
    protected static string $resource = WeddingPaymentScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
