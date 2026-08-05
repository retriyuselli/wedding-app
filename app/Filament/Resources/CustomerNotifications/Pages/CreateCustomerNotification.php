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

    protected int $pushSentCount = 0;

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
        $service = app(BroadcastCustomerNotificationService::class);

        if (! $this->sendToAll) {
            $this->broadcastCount = 1;
            $result = $service->sendToUser((int) $data['user_id'], $data);
            $this->pushSentCount = $result['push_sent'];

            return $result['notification'];
        }

        $result = $service->sendToAllUsers($data);
        $this->broadcastCount = $result['count'];
        $this->pushSentCount = $result['push_sent'];

        return $result['first'];
    }

    protected function getCreatedNotificationTitle(): ?string
    {
        return "Notifikasi dibuat untuk {$this->broadcastCount} user · push terkirim ke {$this->pushSentCount} perangkat";
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
