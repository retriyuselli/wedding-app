<?php

namespace App\Filament\Resources\WeddingIncomingPayments\Schemas;

use App\Models\WeddingIncomingPayment;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class WeddingIncomingPaymentInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('bank_name')
                    ->label('Bank')
                    ->placeholder('-'),
                TextEntry::make('amount')
                    ->money('IDR'),
                TextEntry::make('transfer_date')
                    ->label('Tanggal Transfer')
                    ->date(),
                TextEntry::make('sender_name')
                    ->label('Pengirim'),
                TextEntry::make('description')
                    ->label('Keterangan')
                    ->placeholder('-'),
                TextEntry::make('reference_number')
                    ->label('Nomor Referensi')
                    ->placeholder('-'),
                TextEntry::make('proof_url')
                    ->label('URL Bukti Transfer')
                    ->placeholder('-'),
                TextEntry::make('status')
                    ->formatStateUsing(fn (string $state): string => WeddingIncomingPayment::$statusOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'confirmed' => 'success',
                        'rejected' => 'danger',
                        default => 'warning',
                    }),
                TextEntry::make('confirmed_at')
                    ->label('Dikonfirmasi Pada')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('confirmed_by')
                    ->label('Dikonfirmasi Oleh')
                    ->placeholder('-'),
                TextEntry::make('rejection_reason')
                    ->label('Alasan Penolakan')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('notes')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
