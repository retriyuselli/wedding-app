<?php

namespace App\Filament\Resources\WeddingEvents\Pages;

use App\Filament\Resources\WeddingEvents\WeddingEventResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewWeddingEvent extends ViewRecord
{
    protected static string $resource = WeddingEventResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
