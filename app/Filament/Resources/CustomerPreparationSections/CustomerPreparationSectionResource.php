<?php

namespace App\Filament\Resources\CustomerPreparationSections;

use App\Filament\Resources\CustomerPreparationSections\Pages\CreateCustomerPreparationSection;
use App\Filament\Resources\CustomerPreparationSections\Pages\EditCustomerPreparationSection;
use App\Filament\Resources\CustomerPreparationSections\Pages\ListCustomerPreparationSections;
use App\Filament\Resources\CustomerPreparationSections\Pages\ViewCustomerPreparationSection;
use App\Filament\Resources\CustomerPreparationSections\Schemas\CustomerPreparationSectionForm;
use App\Filament\Resources\CustomerPreparationSections\Schemas\CustomerPreparationSectionInfolist;
use App\Filament\Resources\CustomerPreparationSections\Tables\CustomerPreparationSectionsTable;
use App\Models\CustomerPreparationSection;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class CustomerPreparationSectionResource extends Resource
{
    protected static ?string $model = CustomerPreparationSection::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedFolder;

    protected static string|UnitEnum|null $navigationGroup = 'Persiapan';

    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return CustomerPreparationSectionForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return CustomerPreparationSectionInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CustomerPreparationSectionsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCustomerPreparationSections::route('/'),
            'create' => CreateCustomerPreparationSection::route('/create'),
            'view' => ViewCustomerPreparationSection::route('/{record}'),
            'edit' => EditCustomerPreparationSection::route('/{record}/edit'),
        ];
    }
}
