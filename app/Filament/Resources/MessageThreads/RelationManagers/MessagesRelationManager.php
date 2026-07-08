<?php

namespace App\Filament\Resources\MessageThreads\RelationManagers;

use App\Enums\SupportMessageTopic;
use App\Models\Message;
use App\Services\SupportMessageReplyService;
use Filament\Actions\CreateAction;
use Filament\Forms\Components\Textarea;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class MessagesRelationManager extends RelationManager
{
    protected static string $relationship = 'messages';

    protected static ?string $title = 'Riwayat Pesan';

    protected static ?string $modelLabel = 'Pesan';

    protected static ?string $pluralModelLabel = 'Pesan';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Textarea::make('body')
                    ->label('Balasan Support')
                    ->required()
                    ->rows(4)
                    ->maxLength(5000)
                    ->placeholder('Tulis balasan untuk pengantin...')
                    ->columnSpanFull(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->defaultSort('created_at')
            ->columns([
                TextColumn::make('created_at')
                    ->label('Waktu')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
                TextColumn::make('is_outgoing')
                    ->label('Pengirim')
                    ->formatStateUsing(fn (bool $state): string => $state ? 'Pengantin' : 'Support')
                    ->badge()
                    ->color(fn (bool $state): string => $state ? 'info' : 'success'),
                TextColumn::make('topic')
                    ->label('Topik')
                    ->formatStateUsing(fn (?string $state): string => $state
                        ? (SupportMessageTopic::tryFrom($state)?->label() ?? $state)
                        : '-')
                    ->toggleable(),
                TextColumn::make('body')
                    ->label('Pesan')
                    ->wrap()
                    ->searchable(),
                TextColumn::make('read_at')
                    ->label('Dibaca Pengantin')
                    ->dateTime('d M Y H:i')
                    ->placeholder('Belum dibaca')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->headerActions([
                CreateAction::make()
                    ->label('Kirim Balasan')
                    ->modalHeading('Balas Pesan Support')
                    ->modalSubmitActionLabel('Kirim Balasan')
                    ->successNotificationTitle('Balasan terkirim')
                    ->using(function (array $data): Message {
                        return app(SupportMessageReplyService::class)->reply(
                            $this->getOwnerRecord(),
                            $data['body'],
                        );
                    }),
            ])
            ->emptyStateHeading('Belum ada pesan')
            ->emptyStateDescription('Kirim balasan pertama menggunakan tombol di atas setelah pengantin menghubungi support.');
    }
}
