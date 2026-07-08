<?php

namespace App\Filament\Resources\FamilyMembers\Pages;

use App\Filament\Resources\FamilyMembers\FamilyMemberResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditFamilyMember extends EditRecord
{
    protected static string $resource = FamilyMemberResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
