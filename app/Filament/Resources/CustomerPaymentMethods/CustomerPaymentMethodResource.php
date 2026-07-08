<?php

namespace App\Filament\Resources\CustomerPaymentMethods;

use App\Filament\Resources\CustomerPaymentMethods\Pages\CreateCustomerPaymentMethod;
use App\Filament\Resources\CustomerPaymentMethods\Pages\EditCustomerPaymentMethod;
use App\Filament\Resources\CustomerPaymentMethods\Pages\ListCustomerPaymentMethods;
use App\Filament\Resources\CustomerPaymentMethods\Schemas\CustomerPaymentMethodForm;
use App\Filament\Resources\CustomerPaymentMethods\Tables\CustomerPaymentMethodsTable;
use App\Models\CustomerPaymentMethod;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class CustomerPaymentMethodResource extends Resource
{
    protected static ?string $model = CustomerPaymentMethod::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCreditCard;

    protected static string|UnitEnum|null $navigationGroup = 'Pembayaran';

    protected static ?string $recordTitleAttribute = 'name';

    protected static ?string $modelLabel = 'Metode Pembayaran';

    protected static ?string $pluralModelLabel = 'Metode Pembayaran';

    public static function form(Schema $schema): Schema
    {
        return CustomerPaymentMethodForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CustomerPaymentMethodsTable::configure($table);
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
            'index' => ListCustomerPaymentMethods::route('/'),
            'create' => CreateCustomerPaymentMethod::route('/create'),
            'edit' => EditCustomerPaymentMethod::route('/{record}/edit'),
        ];
    }
}
