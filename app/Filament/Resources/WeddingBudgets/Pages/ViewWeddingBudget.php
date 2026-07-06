<?php

namespace App\Filament\Resources\WeddingBudgets\Pages;

use App\Filament\Resources\WeddingBudgets\WeddingBudgetResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewWeddingBudget extends ViewRecord
{
    protected static string $resource = WeddingBudgetResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
