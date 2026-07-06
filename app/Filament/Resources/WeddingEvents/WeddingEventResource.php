<?php

namespace App\Filament\Resources\WeddingEvents;

use App\Filament\Resources\WeddingEvents\Pages\CreateWeddingEvent;
use App\Filament\Resources\WeddingEvents\Pages\EditWeddingEvent;
use App\Filament\Resources\WeddingEvents\Pages\ListWeddingEvents;
use App\Filament\Resources\WeddingEvents\Pages\ViewWeddingEvent;
use App\Filament\Resources\WeddingEvents\Schemas\WeddingEventForm;
use App\Filament\Resources\WeddingEvents\Schemas\WeddingEventInfolist;
use App\Filament\Resources\WeddingEvents\Tables\WeddingEventsTable;
use App\Models\WeddingEvent;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class WeddingEventResource extends Resource
{
    protected static ?string $model = WeddingEvent::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCalendarDays;

    protected static string|UnitEnum|null $navigationGroup = 'Data Pernikahan';

    protected static ?string $recordTitleAttribute = 'jenis_acara';

    public static function form(Schema $schema): Schema
    {
        return WeddingEventForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return WeddingEventInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return WeddingEventsTable::configure($table);
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
            'index' => ListWeddingEvents::route('/'),
            'create' => CreateWeddingEvent::route('/create'),
            'view' => ViewWeddingEvent::route('/{record}'),
            'edit' => EditWeddingEvent::route('/{record}/edit'),
        ];
    }
}
