<?php

namespace App\Filament\Resources\WeddingQuotes;

use App\Filament\Resources\WeddingQuotes\Pages\CreateWeddingQuote;
use App\Filament\Resources\WeddingQuotes\Pages\EditWeddingQuote;
use App\Filament\Resources\WeddingQuotes\Pages\ListWeddingQuotes;
use App\Filament\Resources\WeddingQuotes\Schemas\WeddingQuoteForm;
use App\Filament\Resources\WeddingQuotes\Tables\WeddingQuotesTable;
use App\Models\WeddingQuote;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class WeddingQuoteResource extends Resource
{
    protected static ?string $model = WeddingQuote::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChatBubbleLeftRight;

    protected static ?string $navigationLabel = 'Quote Carousel';

    protected static ?string $modelLabel = 'Quote';

    protected static ?string $pluralModelLabel = 'Quote Carousel';

    protected static string|UnitEnum|null $navigationGroup = 'Konten Aplikasi';

    public static function form(Schema $schema): Schema
    {
        return WeddingQuoteForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return WeddingQuotesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListWeddingQuotes::route('/'),
            'create' => CreateWeddingQuote::route('/create'),
            'edit' => EditWeddingQuote::route('/{record}/edit'),
        ];
    }
}
