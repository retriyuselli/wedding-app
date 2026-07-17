<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Support\PrivacySettings;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeFill(array $data): array
    {
        $data['partner_user_id'] = PrivacySettings::partnerUserId($this->getRecord());

        return $data;
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        $partnerUserId = $data['partner_user_id'] ?? null;
        unset($data['partner_user_id']);

        $settings = PrivacySettings::forUser($this->getRecord());
        $settings[PrivacySettings::PartnerUserId] = filled($partnerUserId)
            ? (int) $partnerUserId
            : null;

        $data['privacy_settings'] = $settings;

        return $data;
    }
}
