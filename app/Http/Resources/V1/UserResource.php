<?php

namespace App\Http\Resources\V1;

use App\Support\PrivacySettings;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'avatar_url' => $this->avatarUrl(),
            'whatsapp' => $this->whatsapp,
            'notification_settings' => $this->notification_settings,
            'privacy_settings' => PrivacySettings::forUser($this->resource),
            'two_factor_enabled' => (bool) $this->two_factor_enabled,
            'has_social_login' => $this->usesSocialLogin(),
            'password_changed_at' => $this->password_changed_at,
            'roles' => $this->getRoleNames()->values(),
            'is_premium' => $this->isPremium(),
            'premium_product_id' => $this->premium_product_id,
            'premium_activated_at' => $this->premium_activated_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
