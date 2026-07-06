<?php

namespace App\Filament\Resources\VipGuests\Pages;

use App\Filament\Resources\VipGuests\VipGuestResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListVipGuests extends ListRecords
{
    protected static string $resource = VipGuestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
