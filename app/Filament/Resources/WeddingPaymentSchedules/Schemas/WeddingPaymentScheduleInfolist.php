<?php

namespace App\Filament\Resources\WeddingPaymentSchedules\Schemas;

use App\Models\WeddingPaymentSchedule;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class WeddingPaymentScheduleInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Customer'),
                TextEntry::make('weddingEvent.jenis_acara')
                    ->label('Wedding Event')
                    ->placeholder('-'),
                TextEntry::make('paymentMethod.name')
                    ->label('Metode Pembayaran')
                    ->placeholder('-'),
                TextEntry::make('title'),
                TextEntry::make('vendor_name')
                    ->label('Vendor')
                    ->placeholder('-'),
                TextEntry::make('category')
                    ->formatStateUsing(fn (?string $state): string => WeddingPaymentSchedule::$categoryOptions[$state] ?? '-')
                    ->badge(),
                TextEntry::make('amount')
                    ->money('IDR'),
                TextEntry::make('due_date')
                    ->label('Jatuh Tempo')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('status')
                    ->formatStateUsing(fn (string $state): string => WeddingPaymentSchedule::$statusOptions[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'paid' => 'success',
                        'overdue' => 'danger',
                        default => 'warning',
                    }),
                TextEntry::make('paid_at')
                    ->label('Dibayar Pada')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('proof_url')
                    ->label('Bukti Pembayaran')
                    ->formatStateUsing(fn (?string $state): string => $state ? basename($state) : '-')
                    ->url(fn (WeddingPaymentSchedule $record): ?string => $record->proofUrl())
                    ->openUrlInNewTab()
                    ->placeholder('-'),
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
