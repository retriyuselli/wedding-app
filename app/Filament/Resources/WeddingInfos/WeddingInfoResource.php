<?php

namespace App\Filament\Resources\WeddingInfos;

use App\Filament\Resources\WeddingInfos\Pages\CreateWeddingInfo;
use App\Filament\Resources\WeddingInfos\Pages\EditWeddingInfo;
use App\Filament\Resources\WeddingInfos\Pages\ListWeddingInfos;
use App\Filament\Resources\WeddingInfos\Pages\ViewWeddingInfo;
use App\Filament\Resources\WeddingInfos\Schemas\WeddingInfoForm;
use App\Filament\Resources\WeddingInfos\Schemas\WeddingInfoInfolist;
use App\Filament\Resources\WeddingInfos\Tables\WeddingInfosTable;
use App\Models\WeddingInfo;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class WeddingInfoResource extends Resource
{
    protected static ?string $model = WeddingInfo::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedHeart;

    protected static string|UnitEnum|null $navigationGroup = 'Data Pernikahan';

    protected static ?string $recordTitleAttribute = 'groom_name';

    public static function form(Schema $schema): Schema
    {
        return WeddingInfoForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return WeddingInfoInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return WeddingInfosTable::configure($table);
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
            'index' => ListWeddingInfos::route('/'),
            'create' => CreateWeddingInfo::route('/create'),
            'view' => ViewWeddingInfo::route('/{record}'),
            'edit' => EditWeddingInfo::route('/{record}/edit'),
        ];
    }
}
