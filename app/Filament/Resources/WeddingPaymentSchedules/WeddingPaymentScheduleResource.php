<?php

namespace App\Filament\Resources\WeddingPaymentSchedules;

use App\Filament\Resources\WeddingPaymentSchedules\Pages\CreateWeddingPaymentSchedule;
use App\Filament\Resources\WeddingPaymentSchedules\Pages\EditWeddingPaymentSchedule;
use App\Filament\Resources\WeddingPaymentSchedules\Pages\ListWeddingPaymentSchedules;
use App\Filament\Resources\WeddingPaymentSchedules\Schemas\WeddingPaymentScheduleForm;
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

    protected static ?string $modelLabel = 'Jadwal Pembayaran';

    protected static ?string $pluralModelLabel = 'Jadwal Pembayaran';

    public static function form(Schema $schema): Schema
    {
        return WeddingPaymentScheduleForm::configure($schema);
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
            'edit' => EditWeddingPaymentSchedule::route('/{record}/edit'),
        ];
    }
}
