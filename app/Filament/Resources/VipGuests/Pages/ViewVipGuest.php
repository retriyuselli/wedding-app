<?php

namespace App\Filament\Resources\VipGuests\Pages;

use App\Filament\Resources\VipGuests\VipGuestResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewVipGuest extends ViewRecord
{
    protected static string $resource = VipGuestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
