<?php

namespace App\Filament\Resources\WeddingInfos\Pages;

use App\Filament\Resources\WeddingInfos\WeddingInfoResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewWeddingInfo extends ViewRecord
{
    protected static string $resource = WeddingInfoResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
