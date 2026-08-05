<?php

namespace App\Filament\Resources\MessageThreads\Pages;

use App\Filament\Resources\MessageThreads\MessageThreadResource;
use Filament\Resources\Pages\EditRecord;

class EditMessageThread extends EditRecord
{
    protected static string $resource = MessageThreadResource::class;

    protected static ?string $navigationLabel = 'Balas Pesan';

    public function getTitle(): string
    {
        $userName = $this->record->user?->name ?? 'Pengantin';

        return "Support — {$userName}";
    }

    protected function getHeaderActions(): array
    {
        return [];
    }
}
