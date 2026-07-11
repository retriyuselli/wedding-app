<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

#[Fillable(['name', 'email', 'password', 'google_id', 'apple_id', 'avatar_url', 'whatsapp', 'notification_settings'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
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
        return $this->hasMany(WeddingEvent::class)->orderBy('sort_order')->orderBy('tgl_acara');
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

    public function budgetCategoryAllocations(): HasMany
    {
        return $this->hasMany(WeddingBudgetCategoryAllocation::class)->orderBy('category');
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

    public function messageThreads(): HasMany
    {
        return $this->hasMany(MessageThread::class)->latest('updated_at');
    }

    public function deviceTokens(): HasMany
    {
        return $this->hasMany(DeviceToken::class);
    }

    public function savedInspirations(): BelongsToMany
    {
        return $this->belongsToMany(Inspiration::class)->withTimestamps();
    }

    public function likedInspirations(): BelongsToMany
    {
        return $this->belongsToMany(Inspiration::class, 'inspiration_likes')->withTimestamps();
    }

    public function usesSocialLogin(): bool
    {
        return filled($this->google_id) || filled($this->apple_id);
    }

    public function isSuperAdmin(): bool
    {
        return $this->hasRole(config('filament-shield.super_admin.name', 'super_admin'));
    }
}
