<?php

namespace App\Filament\Resources\WeddingEvents\Pages;

use App\Filament\Resources\WeddingEvents\WeddingEventResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListWeddingEvents extends ListRecords
{
    protected static string $resource = WeddingEventResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
