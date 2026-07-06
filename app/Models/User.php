<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

#[Fillable(['name', 'email', 'password', 'avatar_url', 'whatsapp', 'notification_settings'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable, HasRoles;

    protected function casts(): array
    {
        return [
            'email_verified_at'     => 'datetime',
            'password'              => 'hashed',
            'notification_settings' => 'array',
        ];
    }

    public function avatarUrl(): ?string
    {
        if (! $this->avatar_url) {
            return null;
        }

        if (str_starts_with($this->avatar_url, 'http://') || str_starts_with($this->avatar_url, 'https://')) {
            return $this->avatar_url;
        }

        return asset('storage/'.ltrim($this->avatar_url, '/'));
    }

    public function weddingInfo(): HasOne
    {
        return $this->hasOne(WeddingInfo::class);
    }

    public function weddingEvents(): HasMany
    {
        return $this->hasMany(WeddingEvent::class)->orderBy('tgl_acara');
    }

    public function weddingBudget(): HasOne
    {
        return $this->hasOne(WeddingBudget::class);
    }

    public function paymentMethods(): HasMany
    {
        return $this->hasMany(CustomerPaymentMethod::class);
    }

    public function paymentSchedules(): HasMany
    {
        return $this->hasMany(WeddingPaymentSchedule::class)->orderBy('due_date');
    }

    public function incomingPayments(): HasMany
    {
        return $this->hasMany(WeddingIncomingPayment::class)->orderByDesc('transfer_date');
    }

    public function preparationSections(): HasMany
    {
        return $this->hasMany(CustomerPreparationSection::class)->orderBy('sort_order');
    }

    public function familyMembers(): HasMany
    {
        return $this->hasMany(FamilyMember::class);
    }

    public function vipGuests(): HasMany
    {
        return $this->hasMany(VipGuest::class);
    }

    public function guests(): HasMany
    {
        return $this->hasMany(Guest::class);
    }

    public function customerNotifications(): HasMany
    {
        return $this->hasMany(CustomerNotification::class);
    }
}
