<?php

namespace App\Filament\Resources\CustomerNotifications\Pages;

use App\Filament\Resources\CustomerNotifications\CustomerNotificationResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewCustomerNotification extends ViewRecord
{
    protected static string $resource = CustomerNotificationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
