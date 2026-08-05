<?php

namespace App\Filament\Resources\VipGuests\Pages;

use App\Filament\Resources\VipGuests\VipGuestResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditVipGuest extends EditRecord
{
    protected static string $resource = VipGuestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
