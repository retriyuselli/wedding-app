<?php

namespace App\Filament\Resources\WeddingBudgets\Pages;

use App\Filament\Resources\WeddingBudgets\WeddingBudgetResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListWeddingBudgets extends ListRecords
{
    protected static string $resource = WeddingBudgetResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
