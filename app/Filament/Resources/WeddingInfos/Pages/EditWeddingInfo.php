<?php

namespace App\Filament\Resources\WeddingInfos\Pages;

use App\Filament\Resources\WeddingInfos\WeddingInfoResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditWeddingInfo extends EditRecord
{
    protected static string $resource = WeddingInfoResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
