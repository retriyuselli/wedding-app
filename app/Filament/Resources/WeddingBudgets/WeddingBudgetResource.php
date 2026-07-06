<?php

namespace App\Filament\Resources\WeddingBudgets;

use App\Filament\Resources\WeddingBudgets\Pages\CreateWeddingBudget;
use App\Filament\Resources\WeddingBudgets\Pages\EditWeddingBudget;
use App\Filament\Resources\WeddingBudgets\Pages\ListWeddingBudgets;
use App\Filament\Resources\WeddingBudgets\Pages\ViewWeddingBudget;
use App\Filament\Resources\WeddingBudgets\Schemas\WeddingBudgetForm;
use App\Filament\Resources\WeddingBudgets\Schemas\WeddingBudgetInfolist;
use App\Filament\Resources\WeddingBudgets\Tables\WeddingBudgetsTable;
use App\Models\WeddingBudget;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class WeddingBudgetResource extends Resource
{
    protected static ?string $model = WeddingBudget::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBanknotes;

    protected static string|UnitEnum|null $navigationGroup = 'Data Pernikahan';

    public static function form(Schema $schema): Schema
    {
        return WeddingBudgetForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return WeddingBudgetInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return WeddingBudgetsTable::configure($table);
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
            'index' => ListWeddingBudgets::route('/'),
            'create' => CreateWeddingBudget::route('/create'),
            'view' => ViewWeddingBudget::route('/{record}'),
            'edit' => EditWeddingBudget::route('/{record}/edit'),
        ];
    }
}
