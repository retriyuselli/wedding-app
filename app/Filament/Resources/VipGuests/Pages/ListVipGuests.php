<?php

namespace App\Filament\Resources\VipGuests\Pages;

use App\Filament\Resources\VipGuests\VipGuestResource;
use App\Models\User;
use App\Services\VipGuestExcelService;
use Filament\Actions\Action;
use Filament\Actions\CreateAction;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;
use Filament\Support\Icons\Heroicon;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class ListVipGuests extends ListRecords
{
    protected static string $resource = VipGuestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('downloadTemplate')
                ->label('Template Excel')
                ->icon(Heroicon::OutlinedArrowDownTray)
                ->color('gray')
                ->action(fn (): BinaryFileResponse => app(VipGuestExcelService::class)->downloadTemplate()),
            Action::make('importExcel')
                ->label('Upload Excel')
                ->icon(Heroicon::OutlinedArrowUpTray)
                ->modalHeading('Import Tamu VIP dari Excel')
                ->modalDescription('Gunakan template Excel agar kolom sesuai. File yang didukung: .xlsx')
                ->schema([
                    Select::make('user_id')
                        ->label('Pengantin')
                        ->options(fn (): array => User::query()->orderBy('name')->pluck('name', 'id')->all())
                        ->searchable()
                        ->preload()
                        ->required()
                        ->native(false),
                    FileUpload::make('spreadsheet')
                        ->label('File Excel (.xlsx)')
                        ->acceptedFileTypes([
                            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                        ])
                        ->maxSize(10240)
                        ->required()
                        ->disk('local')
                        ->directory('imports/vip-guests')
                        ->visibility('private'),
                ])
                ->action(function (array $data): void {
                    $user = User::query()->findOrFail($data['user_id']);
                    $storedPath = is_array($data['spreadsheet']) ? ($data['spreadsheet'][0] ?? null) : $data['spreadsheet'];

                    if (! is_string($storedPath) || $storedPath === '') {
                        Notification::make()
                            ->title('File Excel tidak ditemukan')
                            ->danger()
                            ->send();

                        return;
                    }

                    $absolutePath = Storage::disk('local')->path($storedPath);
                    $result = app(VipGuestExcelService::class)->import($user, $absolutePath);

                    Storage::disk('local')->delete($storedPath);

                    $body = "Berhasil: {$result['imported']} baris. Dilewati: {$result['skipped']} baris.";

                    if ($result['errors'] !== []) {
                        $body .= "\n".implode("\n", array_slice($result['errors'], 0, 5));
                    }

                    $notification = Notification::make()
                        ->title('Import tamu VIP selesai')
                        ->body($body);

                    if ($result['errors'] !== []) {
                        $notification->warning();
                    } else {
                        $notification->success();
                    }

                    $notification->send();
                }),
            CreateAction::make(),
        ];
    }
}
