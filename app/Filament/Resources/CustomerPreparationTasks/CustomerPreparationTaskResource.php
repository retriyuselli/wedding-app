<?php

namespace App\Filament\Resources\CustomerPreparationTasks;

use App\Filament\Resources\CustomerPreparationTasks\Pages\CreateCustomerPreparationTask;
use App\Filament\Resources\CustomerPreparationTasks\Pages\EditCustomerPreparationTask;
use App\Filament\Resources\CustomerPreparationTasks\Pages\ListCustomerPreparationTasks;
use App\Filament\Resources\CustomerPreparationTasks\Pages\ViewCustomerPreparationTask;
use App\Filament\Resources\CustomerPreparationTasks\Schemas\CustomerPreparationTaskForm;
use App\Filament\Resources\CustomerPreparationTasks\Schemas\CustomerPreparationTaskInfolist;
use App\Filament\Resources\CustomerPreparationTasks\Tables\CustomerPreparationTasksTable;
use App\Models\CustomerPreparationTask;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class CustomerPreparationTaskResource extends Resource
{
    protected static ?string $model = CustomerPreparationTask::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCheckCircle;

    protected static string|UnitEnum|null $navigationGroup = 'Persiapan';

    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return CustomerPreparationTaskForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return CustomerPreparationTaskInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CustomerPreparationTasksTable::configure($table);
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
            'index' => ListCustomerPreparationTasks::route('/'),
            'create' => CreateCustomerPreparationTask::route('/create'),
            'view' => ViewCustomerPreparationTask::route('/{record}'),
            'edit' => EditCustomerPreparationTask::route('/{record}/edit'),
        ];
    }
}
