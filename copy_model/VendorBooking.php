<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\Activitylog\Support\LogOptions;
use Spatie\Activitylog\Models\Concerns\LogsActivity;

class VendorBooking extends Model
{
    use HasFactory, LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly(['status', 'vendor_package_id', 'event_date', 'agreed_total'])
            ->logOnlyDirty()
            ->dontLogEmptyChanges();
    }

    protected $fillable = [
        'vendor_id',
        'user_id',
        'vendor_package_id',
        'agreed_total',
        'dp_required_amount',
        'promo_code',
        'promo_discount',
        'event_date',
        'phone',
        'notes',
        'status',
        'payment_status',
    ];

    protected $casts = [
        'event_date' => 'date',
    ];

    protected function setPhoneAttribute($value): void
    {
        $this->attributes['phone'] = self::normalizeWhatsappNumber($value);
    }

    public static function normalizeWhatsappNumber($value): string
    {
        $digits = preg_replace('/\D+/', '', (string) $value);

        if (str_starts_with($digits, '0')) {
            $digits = '62' . substr($digits, 1);
        }

        if (str_starts_with($digits, '8')) {
            $digits = '62' . $digits;
        }

        if (str_starts_with($digits, '620')) {
            $digits = '62' . substr($digits, 3);
        }

        return $digits;
    }

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function vendorPackage()
    {
        return $this->belongsTo(VendorPackage::class);
    }

    public function payments()
    {
        return $this->hasMany(\App\Models\VendorBookingPayment::class);
    }
}
