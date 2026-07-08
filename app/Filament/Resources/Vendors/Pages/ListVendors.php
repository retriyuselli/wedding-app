<?php

namespace App\Filament\Resources\Vendors\Pages;

use App\Filament\Resources\Vendors\Tables\VendorsTable;
use App\Filament\Resources\Vendors\VendorResource;
use Filament\Actions\Action;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;
use Filament\Tables\Table;

class ListVendors extends ListRecords
{
    protected static string $resource = VendorResource::class;

    public function table(Table $table): Table
    {
        return VendorsTable::configure($table)
            ->reorderable('sort_order')
            ->reorderRecordsTriggerAction(
                fn (Action $action, bool $isReordering): Action => $action
                    ->label($isReordering ? 'Selesai urutkan' : 'Atur urutan'),
            );
    }

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
