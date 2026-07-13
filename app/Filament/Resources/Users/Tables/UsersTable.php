<?php

namespace App\Filament\Resources\Users\Tables;

use App\Models\User;
use Filament\Actions\Action;
use Filament\Actions\BulkAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Auth;

class UsersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query->with('roles'))
            ->defaultSort('created_at', 'desc')
            ->striped()
            ->persistSearchInSession()
            ->persistFiltersInSession()
            ->persistSortInSession()
            ->columns([
                ImageColumn::make('avatar_url')
                    ->label('Avatar')
                    ->circular()
                    ->getStateUsing(fn (User $record): ?string => $record->avatarUrl())
                    ->defaultImageUrl(fn (User $record): string => 'https://ui-avatars.com/api/?name='.urlencode($record->name).'&background=E8EDE6&color=3D5A45')
                    ->toggleable(),
                TextColumn::make('name')
                    ->label('Pengguna')
                    ->searchable(['name', 'email'])
                    ->sortable()
                    ->weight('medium')
                    ->description(fn (User $record): string => $record->email)
                    ->copyable()
                    ->copyMessage('Email disalin')
                    ->copyableState(fn (User $record): string => $record->email),
                TextColumn::make('whatsapp')
                    ->label('WhatsApp')
                    ->searchable()
                    ->placeholder('—')
                    ->url(fn (User $record): ?string => filled($record->whatsapp)
                        ? 'https://wa.me/'.preg_replace('/\D+/', '', $record->whatsapp)
                        : null)
                    ->openUrlInNewTab()
                    ->icon(fn (User $record): ?string => filled($record->whatsapp) ? 'heroicon-o-chat-bubble-left-right' : null)
                    ->toggleable(),
                TextColumn::make('roles.name')
                    ->label('Role')
                    ->badge()
                    ->separator(',')
                    ->placeholder('Tanpa role')
                    ->color(fn (string $state): string => match ($state) {
                        'super_admin' => 'danger',
                        'admin' => 'warning',
                        'panel_user' => 'info',
                        default => 'gray',
                    }),
                IconColumn::make('email_verified_at')
                    ->label('Email')
                    ->boolean()
                    ->alignCenter()
                    ->trueIcon('heroicon-o-check-badge')
                    ->falseIcon('heroicon-o-exclamation-circle')
                    ->trueColor('success')
                    ->falseColor('warning')
                    ->tooltip(fn (User $record): string => filled($record->email_verified_at)
                        ? 'Terverifikasi '.$record->email_verified_at->format('d M Y H:i')
                        : 'Belum verifikasi')
                    ->state(fn (User $record): bool => filled($record->email_verified_at)),
                TextColumn::make('login_provider')
                    ->label('Login')
                    ->state(function (User $record): string {
                        if (filled($record->google_id)) {
                            return 'Google';
                        }

                        if (filled($record->apple_id)) {
                            return 'Apple';
                        }

                        return 'Email';
                    })
                    ->badge()
                    ->icon(fn (string $state): string => match ($state) {
                        'Google' => 'heroicon-o-globe-alt',
                        'Apple' => 'heroicon-o-device-phone-mobile',
                        default => 'heroicon-o-envelope',
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'Google' => 'info',
                        'Apple' => 'gray',
                        default => 'success',
                    }),
                TextColumn::make('created_at')
                    ->label('Bergabung')
                    ->dateTime('d M Y')
                    ->sortable()
                    ->description(fn (User $record): string => $record->created_at?->diffForHumans() ?? '')
                    ->toggleable(),
                TextColumn::make('updated_at')
                    ->label('Diperbarui')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                TernaryFilter::make('email_verified_at')
                    ->label('Email terverifikasi')
                    ->nullable()
                    ->trueLabel('Sudah verifikasi')
                    ->falseLabel('Belum verifikasi')
                    ->placeholder('Semua'),
                SelectFilter::make('roles')
                    ->label('Role')
                    ->relationship('roles', 'name')
                    ->multiple()
                    ->preload()
                    ->searchable(),
                SelectFilter::make('login_provider')
                    ->label('Metode login')
                    ->options([
                        'email' => 'Email',
                        'google' => 'Google',
                        'apple' => 'Apple',
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return match ($data['value'] ?? null) {
                            'google' => $query->whereNotNull('google_id'),
                            'apple' => $query->whereNotNull('apple_id'),
                            'email' => $query->whereNull('google_id')->whereNull('apple_id'),
                            default => $query,
                        };
                    }),
            ])
            ->filtersTriggerAction(
                fn (Action $action): Action => $action
                    ->button()
                    ->label('Filter'),
            )
            ->recordActions([
                EditAction::make()
                    ->label('Edit'),
                Action::make('verifyEmail')
                    ->label('Verifikasi')
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn (User $record): bool => blank($record->email_verified_at))
                    ->requiresConfirmation()
                    ->modalHeading('Verifikasi email user?')
                    ->modalDescription(fn (User $record): string => "Tandai {$record->email} sebagai sudah terverifikasi.")
                    ->action(fn (User $record) => $record->forceFill(['email_verified_at' => now()])->save()),
                DeleteAction::make()
                    ->visible(fn (User $record): bool => Auth::id() !== $record->id),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    BulkAction::make('verifySelected')
                        ->label('Tandai terverifikasi')
                        ->icon('heroicon-o-check-badge')
                        ->color('success')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->action(function (Collection $records): void {
                            $records->each(function (User $record): void {
                                if (blank($record->email_verified_at)) {
                                    $record->forceFill(['email_verified_at' => now()])->save();
                                }
                            });
                        }),
                    DeleteBulkAction::make()
                        ->action(function (Collection $records): void {
                            $records
                                ->reject(fn (User $record): bool => Auth::id() === $record->id)
                                ->each->delete();
                        }),
                ]),
            ])
            ->emptyStateHeading('Belum ada user')
            ->emptyStateDescription('User pengantin dan admin akan muncul di sini setelah dibuat atau registrasi.')
            ->emptyStateIcon('heroicon-o-users');
    }
}
