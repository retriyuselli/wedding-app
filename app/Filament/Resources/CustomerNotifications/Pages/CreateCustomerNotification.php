<?php

namespace App\Filament\Resources\CustomerNotifications\Pages;

use App\Filament\Resources\CustomerNotifications\CustomerNotificationResource;
use App\Models\CustomerNotification;
use App\Services\BroadcastCustomerNotificationService;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Database\Eloquent\Model;

class CreateCustomerNotification extends CreateRecord
{
    protected static string $resource = CustomerNotificationResource::class;

    protected int $broadcastCount = 1;

    protected bool $sendToAll = false;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $this->sendToAll = (bool) ($data['send_to_all'] ?? false);
        unset($data['send_to_all']);

        return $data;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    protected function handleRecordCreation(array $data): Model
    {
        if (! $this->sendToAll) {
            $this->broadcastCount = 1;

            return static::getModel()::create($data);
        }

        $result = app(BroadcastCustomerNotificationService::class)->sendToAllUsers($data);
        $this->broadcastCount = $result['count'];

        return $result['first'];
    }

    protected function getCreatedNotificationTitle(): ?string
    {
        if ($this->broadcastCount > 1) {
            return "Notifikasi dikirim ke {$this->broadcastCount} user";
        }

        return parent::getCreatedNotificationTitle();
    }

    protected function getRedirectUrl(): string
    {
        if ($this->broadcastCount > 1) {
            return CustomerNotificationResource::getUrl('index');
        }

        /** @var CustomerNotification $record */
        $record = $this->getRecord();

        return CustomerNotificationResource::getUrl('edit', ['record' => $record]);
    }
}
