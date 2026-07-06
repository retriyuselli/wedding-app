<?php

namespace App\Filament\Resources\CustomerPaymentMethods\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class CustomerPaymentMethodInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('name'),
                TextEntry::make('logo_icon')
                    ->placeholder('-'),
                TextEntry::make('account_number')
                    ->placeholder('-'),
                TextEntry::make('account_name')
                    ->placeholder('-'),
                IconEntry::make('is_primary')
                    ->boolean(),
                TextEntry::make('type')
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
