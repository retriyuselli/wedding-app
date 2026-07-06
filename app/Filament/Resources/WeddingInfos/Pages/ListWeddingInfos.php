<?php

namespace App\Filament\Resources\WeddingInfos\Pages;

use App\Filament\Resources\WeddingInfos\WeddingInfoResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListWeddingInfos extends ListRecords
{
    protected static string $resource = WeddingInfoResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
