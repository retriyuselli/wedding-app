<?php

namespace App\Filament\Resources\MessageThreads\Pages;

use App\Filament\Resources\MessageThreads\MessageThreadResource;
use Filament\Resources\Pages\ListRecords;

class ListMessageThreads extends ListRecords
{
    protected static string $resource = MessageThreadResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
