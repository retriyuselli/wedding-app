<?php

namespace App\Filament\Resources\VipGuests\Pages;

use App\Filament\Resources\VipGuests\VipGuestResource;
use Filament\Resources\Pages\CreateRecord;

class CreateVipGuest extends CreateRecord
{
    protected static string $resource = VipGuestResource::class;
}
