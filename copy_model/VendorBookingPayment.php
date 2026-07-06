<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\Activitylog\Support\LogOptions;
use Spatie\Activitylog\Models\Concerns\LogsActivity;

class VendorBookingPayment extends Model
{
    use HasFactory, LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logFillable()
            ->logOnlyDirty()
            ->dontLogEmptyChanges();
    }

    protected $fillable = [
        'vendor_booking_id',
        'type',
        'due_date',
        'amount',
        'method',
        'sender_name',
        'sender_bank',
        'paid_at',
        'proof_path',
        'status',
        'verified_by',
        'verified_at',
        'note',
    ];

    protected $casts = [
        'amount'       => 'integer',
        'due_date'     => 'date',
        'paid_at'      => 'datetime',
        'verified_at'  => 'datetime',
    ];

    public function booking()
    {
        return $this->belongsTo(VendorBooking::class, 'vendor_booking_id');
    }

    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function getProofUrlAttribute(): ?string
    {
        if (!$this->proof_path) {
            return null;
        }
        if (str_starts_with($this->proof_path, 'http')) {
            return $this->proof_path;
        }
        return asset('storage/' . ltrim($this->proof_path, '/'));
    }
}
