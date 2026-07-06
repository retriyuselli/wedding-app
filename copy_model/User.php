<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use App\Models\DeviceToken;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Filament\Models\Contracts\HasAvatar;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;
use Spatie\Activitylog\Support\LogOptions;
use Spatie\Activitylog\Models\Concerns\LogsActivity;

#[Fillable(['name', 'email', 'password', 'avatar_url', 'apple_id', 'theme_color', 'email_verified_at', 'whatsapp', 'notification_settings'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable implements FilamentUser, HasAvatar, MustVerifyEmail
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable, LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly(['name', 'email', 'avatar_url', 'whatsapp'])
            ->logOnlyDirty()
            ->dontLogEmptyChanges();
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return $this->hasRole(['super_admin', 'admin']);
    }

    public function isAdmin(): bool
    {
        return $this->hasRole(['super_admin', 'admin']);
    }

    public function isVendor(): bool
    {
        return $this->hasRole('vendor');
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at'     => 'datetime',
            'password'              => 'hashed',
            'notification_settings' => 'array',
        ];
    }

    public function getFilamentAvatarUrl(): ?string
    {
        return $this->avatarUrl();
    }

    public function avatarUrl(): ?string
    {
        if (!$this->avatar_url) {
            return null;
        }

        // External URL (e.g. Google) — return as-is
        if (str_starts_with($this->avatar_url, 'http://') || str_starts_with($this->avatar_url, 'https://')) {
            return $this->avatar_url;
        }

        return asset('storage/' . ltrim($this->avatar_url, '/'));
    }

    protected function setWhatsappAttribute($value): void
    {
        $this->attributes['whatsapp'] = VendorBooking::normalizeWhatsappNumber($value);
    }

    public function vendorReviews()
    {
        return $this->hasMany(VendorReview::class);
    }

    public function vendorBookings()
    {
        return $this->hasMany(VendorBooking::class);
    }

    /**
     * Get the vendors that the user has liked.
     */
    public function likedVendors()
    {
        return $this->belongsToMany(Vendor::class, 'vendor_user_likes')->withTimestamps();
    }

    public function wishlists()
    {
        return $this->hasMany(Wishlist::class);
    }

    public function wishlistedPackages()
    {
        return $this->belongsToMany(VendorPackage::class, 'wishlists')->withTimestamps();
    }

    public function deviceTokens()
    {
        return $this->hasMany(DeviceToken::class);
    }

    public function weddingInfo(): HasOne
    {
        return $this->hasOne(WeddingInfo::class);
    }

    public function familyMembers(): HasMany
    {
        return $this->hasMany(FamilyMember::class);
    }

    public function paymentMethods(): HasMany
    {
        return $this->hasMany(CustomerPaymentMethod::class);
    }

    public function weddingBudget(): HasOne
    {
        return $this->hasOne(WeddingBudget::class);
    }

    public function paymentSchedules(): HasMany
    {
        return $this->hasMany(WeddingPaymentSchedule::class)->orderBy('due_date');
    }

    public function incomingPayments(): HasMany
    {
        return $this->hasMany(WeddingIncomingPayment::class)->orderByDesc('transfer_date');
    }

    public function customerNotifications(): HasMany
    {
        return $this->hasMany(CustomerNotification::class);
    }

    public function preparationSections(): HasMany
    {
        return $this->hasMany(CustomerPreparationSection::class)->orderBy('sort_order');
    }

    public function weddingEvents(): HasMany
    {
        return $this->hasMany(WeddingEvent::class)->orderBy('tgl_acara');
    }

    public function vipGuests(): HasMany
    {
        return $this->hasMany(VipGuest::class);
    }
}
