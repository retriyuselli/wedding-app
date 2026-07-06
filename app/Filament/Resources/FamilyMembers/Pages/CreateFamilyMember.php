<?php

namespace App\Filament\Resources\FamilyMembers\Pages;

use App\Filament\Resources\FamilyMembers\FamilyMemberResource;
use Filament\Resources\Pages\CreateRecord;

class CreateFamilyMember extends CreateRecord
{
    protected static string $resource = FamilyMemberResource::class;
}
