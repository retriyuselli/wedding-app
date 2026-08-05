<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Models\User;
use App\Support\PrivacySettings;
use Filament\Actions\DeleteAction;
use Filament\Facades\Filament;
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    /** @var list<int|string>|null */
    private ?array $roleIdsBeforeSave = null;

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

        $this->roleIdsBeforeSave = $this->getRecord()->roles()->pluck('id')->all();

        if (! $this->actorIsSuperAdmin()) {
            unset(
                $data['is_premium'],
                $data['premium_product_id'],
                $data['premium_activated_at'],
                $data['apple_original_transaction_id'],
            );
        }

        return $data;
    }

    protected function afterSave(): void
    {
        if ($this->actorIsSuperAdmin() || $this->roleIdsBeforeSave === null) {
            return;
        }

        $this->getRecord()->roles()->sync($this->roleIdsBeforeSave);
    }

    private function actorIsSuperAdmin(): bool
    {
        $actor = Filament::auth()->user() ?? auth()->user();

        return $actor instanceof User && $actor->isSuperAdmin();
    }
}
