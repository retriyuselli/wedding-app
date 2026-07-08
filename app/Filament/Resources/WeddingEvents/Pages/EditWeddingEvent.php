<?php

namespace App\Filament\Resources\WeddingEvents\Pages;

use App\Filament\Resources\WeddingEvents\WeddingEventResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditWeddingEvent extends EditRecord
{
    protected static string $resource = WeddingEventResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
