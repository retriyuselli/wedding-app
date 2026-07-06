<?php

namespace App\Filament\Resources\WeddingQuotes\Pages;

use App\Filament\Resources\WeddingQuotes\WeddingQuoteResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListWeddingQuotes extends ListRecords
{
    protected static string $resource = WeddingQuoteResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
