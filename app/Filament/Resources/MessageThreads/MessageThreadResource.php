<?php

namespace App\Filament\Resources\MessageThreads;

use App\Filament\Resources\MessageThreads\Pages\EditMessageThread;
use App\Filament\Resources\MessageThreads\Pages\ListMessageThreads;
use App\Filament\Resources\MessageThreads\RelationManagers\MessagesRelationManager;
use App\Filament\Resources\MessageThreads\Schemas\MessageThreadForm;
use App\Filament\Resources\MessageThreads\Tables\MessageThreadsTable;
use App\Models\MessageThread;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

class MessageThreadResource extends Resource
{
    protected static ?string $model = MessageThread::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChatBubbleLeftRight;

    protected static string|UnitEnum|null $navigationGroup = 'Komunikasi';

    protected static ?string $navigationLabel = 'Pesan Support';

    protected static ?string $modelLabel = 'Pesan Support';

    protected static ?string $pluralModelLabel = 'Pesan Support';

    protected static ?string $recordTitleAttribute = 'name';

    protected static ?int $navigationSort = 1;

    public static function form(Schema $schema): Schema
    {
        return MessageThreadForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return MessageThreadsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            MessagesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListMessageThreads::route('/'),
            'edit' => EditMessageThread::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->where('category', 'support')
            ->with(['user', 'latestMessage']);
    }

    public static function canCreate(): bool
    {
        return false;
    }
}
