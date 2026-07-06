<?php

namespace App\Filament\Resources\WeddingPaymentSchedules;

use App\Filament\Resources\WeddingPaymentSchedules\Pages\CreateWeddingPaymentSchedule;
use App\Filament\Resources\WeddingPaymentSchedules\Pages\EditWeddingPaymentSchedule;
use App\Filament\Resources\WeddingPaymentSchedules\Pages\ListWeddingPaymentSchedules;
use App\Filament\Resources\WeddingPaymentSchedules\Pages\ViewWeddingPaymentSchedule;
use App\Filament\Resources\WeddingPaymentSchedules\Schemas\WeddingPaymentScheduleForm;
use App\Filament\Resources\WeddingPaymentSchedules\Schemas\WeddingPaymentScheduleInfolist;
use App\Filament\Resources\WeddingPaymentSchedules\Tables\WeddingPaymentSchedulesTable;
use App\Models\WeddingPaymentSchedule;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class WeddingPaymentScheduleResource extends Resource
{
    protected static ?string $model = WeddingPaymentSchedule::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCalendarDateRange;

    protected static string|UnitEnum|null $navigationGroup = 'Pembayaran';

    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return WeddingPaymentScheduleForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return WeddingPaymentScheduleInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return WeddingPaymentSchedulesTable::configure($table);
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
            'index' => ListWeddingPaymentSchedules::route('/'),
            'create' => CreateWeddingPaymentSchedule::route('/create'),
            'view' => ViewWeddingPaymentSchedule::route('/{record}'),
            'edit' => EditWeddingPaymentSchedule::route('/{record}/edit'),
        ];
    }
}
