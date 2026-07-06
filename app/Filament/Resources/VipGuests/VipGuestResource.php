<?php

namespace App\Filament\Resources\VipGuests;

use App\Filament\Resources\VipGuests\Pages\CreateVipGuest;
use App\Filament\Resources\VipGuests\Pages\EditVipGuest;
use App\Filament\Resources\VipGuests\Pages\ListVipGuests;
use App\Filament\Resources\VipGuests\Pages\ViewVipGuest;
use App\Filament\Resources\VipGuests\Schemas\VipGuestForm;
use App\Filament\Resources\VipGuests\Schemas\VipGuestInfolist;
use App\Filament\Resources\VipGuests\Tables\VipGuestsTable;
use App\Models\VipGuest;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class VipGuestResource extends Resource
{
    protected static ?string $model = VipGuest::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedStar;

    protected static string|UnitEnum|null $navigationGroup = 'Tamu';

    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return VipGuestForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return VipGuestInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return VipGuestsTable::configure($table);
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
            'index' => ListVipGuests::route('/'),
            'create' => CreateVipGuest::route('/create'),
            'view' => ViewVipGuest::route('/{record}'),
            'edit' => EditVipGuest::route('/{record}/edit'),
        ];
    }
}
