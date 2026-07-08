<?php

namespace App\Filament\Resources\WeddingIncomingPayments;

use App\Filament\Resources\WeddingIncomingPayments\Pages\CreateWeddingIncomingPayment;
use App\Filament\Resources\WeddingIncomingPayments\Pages\EditWeddingIncomingPayment;
use App\Filament\Resources\WeddingIncomingPayments\Pages\ListWeddingIncomingPayments;
use App\Filament\Resources\WeddingIncomingPayments\Schemas\WeddingIncomingPaymentForm;
use App\Filament\Resources\WeddingIncomingPayments\Tables\WeddingIncomingPaymentsTable;
use App\Models\WeddingIncomingPayment;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class WeddingIncomingPaymentResource extends Resource
{
    protected static ?string $model = WeddingIncomingPayment::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedArrowDownTray;

    protected static string|UnitEnum|null $navigationGroup = 'Pembayaran';

    protected static ?string $recordTitleAttribute = 'sender_name';

    protected static ?string $modelLabel = 'Uang Masuk';

    protected static ?string $pluralModelLabel = 'Uang Masuk';

    public static function form(Schema $schema): Schema
    {
        return WeddingIncomingPaymentForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return WeddingIncomingPaymentsTable::configure($table);
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
            'index' => ListWeddingIncomingPayments::route('/'),
            'create' => CreateWeddingIncomingPayment::route('/create'),
            'edit' => EditWeddingIncomingPayment::route('/{record}/edit'),
        ];
    }
}
